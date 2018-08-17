#!/bin/bash -e

# Compute UID and GID mappings that use both our IDs and the ones that are
# allocated for us in /etc/subuid and /etc/subgid.
#
# If invoked with -U but NOT with -r, set mappings using newuidmap/newgidmap.
#
# Probably doesn't handle PID namespaces correctly, since we trust the child
# to tell us its PID.

uidmap="0 $(id -u) 1"
gidmap="0 $(id -g) 1"
subuid=$(grep "^${USER}:" /etc/subuid | sed -r -e "s,[^:]*:,," -e "s,:, ,")
subgid=$(grep "^${USER}:" /etc/subgid | sed -r -e "s,[^:]*:,," -e "s,:, ,")
cid=1
while read hid size ; do
	uidmap="${uidmap} ${cid} ${hid} ${size}"
	cid=$(( ${cid} + ${size} ))
done <<< "${subuid}"
cid=1
while read hid size ; do
	gidmap="${gidmap} ${cid} ${hid} ${size}"
	cid=$(( ${cid} + ${size} ))
done <<< "${subgid}"

# Create a script to run the command we actually want to run, and a file to
# use for loose synchronization.
script=$(mktemp)
if test -z "${script}" ; then
	echo error creating temporary script
	exit 1
fi
pidfile=$(mktemp)
if test -z "${pidfile}" ; then
	echo error creating temporary pidfile
	exit 1
fi
trap "rm -f ${script} ${pidfile}" EXIT

# How much time to wait between checking for synchronization steps.
delay=0.01

# A function to clear the pid file.
function clearpidfile() {
	while ! test -s ${pidfile} ; do
		sleep ${delay}
	done
	: > ${pidfile}
}

# A function to read the pid file and set its ID maps.
function setmap() {
	while ! test -s ${pidfile} ; do
		sleep ${delay}
	done
	pid=$(cat ${pidfile})
	newgidmap $pid $gidmap
	newuidmap $pid $uidmap
	: > ${pidfile}
}

# Filter flags for unshare from what comes after.
while test -n "${1}" ; do
	case "${1}" in
	-*)
		flags="${flags} ${1}"
		shift
		;;
	*)
		break
		;;
	esac
done

# A wrapper script to save its PID to the pidfile, wait for the file
# to be truncated, and then execute the commands that we got on the
# command line.
chmod +x ${script}
cat > ${script} <<- EOF
#!/bin/bash
echo \$\$ > ${pidfile}
while test -s ${pidfile} ; do
	sleep ${delay}
done
sh -c "$@"
EOF
if grep -q U <<< "$flags" && ! grep -q r <<< "$flags" ; then
	coproc setmap
else
	coproc clearpidfile
fi
exec unshare ${flags} ${script}
