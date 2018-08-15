#!/bin/bash
rm -fr $(pwd)/root
set -x
dnf -y --installroot $(pwd)/root --disablerepo="*" --enablerepo=fedora --enablerepo=updates --nogpgcheck --releasever=28 --nodocs install glibc-langpack-en "$@"
dnf -y --installroot $(pwd)/root clean all
