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

./unshare2.sh -Um dnf -y install   --releasever=28 --installroot $(pwd)/root --disablerepo="*" --enablerepo=fedora --enablerepo=updates --nogpgcheck --nodocs --setopt install_weak_deps=false glibc-langpack-en "${@:-doge}"
./unshare2.sh -Um dnf -y clean all --releasever=28 --installroot $(pwd)/root

( cd root ; $HOME/projects/containers/buildah/src/github.com/projectatomic/buildah/buildah unshare tar cf - . ) | gzip > layer2.tar.gz
