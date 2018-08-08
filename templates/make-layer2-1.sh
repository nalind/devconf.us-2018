#!/bin/bash -x
#
#  Create a root filesystem with just busybox in the /bin directory.
#
if test -d root ; then
	chmod -R u+rw root
	rm -fr root
fi
mkdir -p root/bin

cp /usr/sbin/busybox root/bin/

( cd root ; tar cf - . ) | gzip > layer2.tar.gz
