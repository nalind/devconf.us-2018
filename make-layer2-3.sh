#!/bin/bash -x
#
#  Create a root filesystem with the specified packages.
#  Create the archive in a user namespace that makes files that are
#  owned by me appear to be owned by root.
#
if test -d root ; then
	chmod -R u+rw root
	rm -fr root
fi
mkdir -p root

unshare -Ur dnf -y install --nogpgcheck --releasever=28 --installroot $(pwd)/root glibc-langpack-en "${@:-doge}"
unshare -Ur dnf -y clean all            --releasever=28 --installroot $(pwd)/root

( cd root ; unshare -Ur tar cf - . ) | gzip > layer2.tar.gz
