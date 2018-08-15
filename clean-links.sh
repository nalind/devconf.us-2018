#!/bin/bash

# Remove any symbolic links in the current directory.
find -maxdepth 1 -type l | xargs -r rm -v
