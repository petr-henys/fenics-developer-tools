#!/usr/bin/env sh
#
# This script clones all FEniCS repositories to the current directory
# See README.rst for details.

# Tell script to exit on first error
set -e

# Clone all FEniCS git repos
echo "Cloning sources for all FEniCS packages, this may take a few minutes..."
for p in dijitso instant fiat ufl ffc dolfin mshr; do
    echo
    if [ -d ${p} ]; then
	echo "Directory ${p} exists, skipping."
    else
	echo "Downloading ${p}..."
        git clone git@bitbucket.org:fenics-project/${p}.git
        cd ${p}
        git checkout -b next origin/next
        git pull
        git checkout master
        cd ..
    fi
done
