#!/bin/bash -x
#
#  Create a root filesystem with just busybox in the /bin directory.
#  Create the archive in a user namespace that makes files that are
#  owned by me appear to be owned by root.
#
if test -d root ; then
	chmod -R u+rw root
	rm -fr root
fi
mkdir -p root/bin

cp /usr/sbin/busybox root/bin/

( cd root ; unshare -Ur tar cf - . ) | gzip > layer2.tar.gz
