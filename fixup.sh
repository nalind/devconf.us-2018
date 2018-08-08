#!/bin/bash

# Remove any symbolic links in the current directory.
find -maxdepth 1 -type l | xargs -r rm -v

# Create symbolic links to any files matching ".tar", ".json", and ".tar.*"
# that are based on the digest of their contents.
for file in *.tar *.json *.tar.* ; do
	if test -s "$file" ; then
		ln -vs "$file" $(sha256sum -b "$file" | cut -c-64)
	fi
done
