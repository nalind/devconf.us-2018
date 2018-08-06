#!/bin/bash -x
#
#  Create a root filesystem with the specified packages.
#  Create the archive in a user namespace that makes files that are
#  owned by me appear to be owned by root, and which maps in ranges
#  that /etc/subuid and /etc/subgid say that I'm also allowed to
#  use, to use for system user and group IDs.
#
if test -d root ; then
	chmod -R u+rw root
	rm -fr root
fi
mkdir -p root

$HOME/projects/containers/buildah/src/github.com/projectatomic/buildah/buildah unshare dnf -y install --nogpgcheck --releasever=28 --installroot $(pwd)/root glibc-langpack-en "${@:-doge}"
$HOME/projects/containers/buildah/src/github.com/projectatomic/buildah/buildah unshare dnf -y clean all            --releasever=28 --installroot $(pwd)/root

( cd root ; $HOME/projects/containers/buildah/src/github.com/projectatomic/buildah/buildah unshare tar cf - . ) | gzip > layer2.tar.gz
