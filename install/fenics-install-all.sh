#!/usr/bin/env bash
#
# This script sets up a FEniCS developer environment.
# See README.rst for details.
#
# Environment variables:
#
#   FENICS_INSTALL_NAME       (must be set)
#   FENICS_INSTALL_PREFIX     (optional)
#   FENICS_SOURCE_PREFIX      (optional)

# Exit on first error
set -e

# Check that FENICS_INSTALL_NAME has been set
if [ -z "${FENICS_INSTALL_NAME}" ]; then
    echo "*** Environment variable FENICS_INSTALL_NAME must be set."
    echo "*** Sensible choices are 'master', 'foo', '1.4', '1.5', 'master-1976-01-07', etc."
    exit 1
fi

THIS_DIR="$(cd "$(dirname "$0")" && pwd)"

# Get base prefixes, nothing will be placed outside these directories
: ${FENICS_SOURCE_BASE_PREFIX:=${HOME}/dev/fenics-dev}
: ${FENICS_INSTALL_BASE_PREFIX:=${HOME}/opt/fenics-dev}

# Get source prefix
: ${FENICS_SOURCE_PREFIX:=${FENICS_SOURCE_BASE_PREFIX}/${FENICS_INSTALL_NAME}}
mkdir -p ${FENICS_SOURCE_PREFIX}
echo "Source prefix set to '${FENICS_SOURCE_PREFIX}'."

# Use Python to get full path to a file (realpath is not available on OS X)
realpath() {
    echo $(python -c "import os,sys;print(os.path.realpath(sys.argv[1]))" $1)
}

# Check if a profile is given as an environment variable
if [ ! -z ${FENICS_INSTALL_HASHDIST_PROFILE} ]
then
    HASHDIST_PROFILE=$(realpath ${FENICS_INSTALL_HASHDIST_PROFILE})
fi

# Build dependencies by calling fenics-install.sh
echo "Building FEniCS dependencies using fenics-install.sh."
cd ${FENICS_SOURCE_PREFIX}
if [ ! -z ${HASHDIST_PROFILE} ]; then
    FENICS_INSTALL_HASHDIST_PROFILE=${HASHDIST_PROFILE} ${THIS_DIR}/fenics-install.sh
    mv fenics.custom fenics.deps
else
    FENICS_INSTALL_BUILD_TYPE=2 ${THIS_DIR}/fenics-install.sh
fi

# Make dependencies and PROFILE available in paths for building
source ${FENICS_SOURCE_PREFIX}/fenics.deps

# Get installation prefix
: ${FENICS_INSTALL_PREFIX:="${FENICS_INSTALL_BASE_PREFIX}/${PROFILE}/${FENICS_INSTALL_NAME}"}
mkdir -p ${FENICS_INSTALL_PREFIX}
echo "Installation prefix set to '${FENICS_INSTALL_PREFIX}'."
export FENICS_INSTALL_PREFIX

# Copy fenics.deps
cp ${FENICS_SOURCE_PREFIX}/fenics.deps ${FENICS_INSTALL_PREFIX}/..

# Clone all FEniCS git repos
cd ${FENICS_SOURCE_PREFIX}
echo "Cloning sources for all FEniCS packages."
for p in instant fiat ufl dijitso ffc dolfin mshr; do
    echo
    echo "Downloading ${p}..."
    if [ -d ${p} ]; then
        cd ${p}
        git checkout master
        git pull
        cd ..
    else
        git clone https://bitbucket.org/fenics-project/${p}.git
    fi
done

# Build all projects except dolfin and mshr
for p in instant fiat ufl dijitso ffc; do
    echo
    echo "Configuring, building and installing ${p}..."
    cd ${FENICS_SOURCE_PREFIX}/$p
    ${THIS_DIR}/fenics-install-component.sh
done

# Build DOLFIN (requires other components in path already)
source ${FENICS_INSTALL_PREFIX}/fenics.conf
cd ${FENICS_SOURCE_PREFIX}/dolfin
${THIS_DIR}/fenics-install-component.sh

# Build mshr
cd ${FENICS_SOURCE_PREFIX}/mshr
${THIS_DIR}/fenics-install-component.sh

# Print information (add to info from fenics-install-component.sh)
echo "- FEniCS sources can be found in ${FENICS_SOURCE_PREFIX}"
echo
