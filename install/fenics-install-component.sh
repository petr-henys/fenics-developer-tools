#!/usr/bin/env bash
#
# This configures, builds and installs a single FEniCS package.
# See README.rst for details.
#
# Environment variables:
#
#   FENICS_INSTALL_NAME       (must be set)
#   FENICS_INSTALL_PREFIX     (optional)
#   FENICS_PYTHON_EXECUTABLE  (optional)
#   FENICS_ALIAS_FILE         (optional)
#   PROFILE                   (optional)
#   PROCS                     (optional)

# Exit on first error
set -e

# Check operating system
OS=$(uname)

# Check that FENICS_INSTALL_NAME has been set
if [ -z "${FENICS_INSTALL_NAME}" ]; then
    echo "*** Environment variable FENICS_INSTALL_NAME must be set."
    echo "*** Sensible choices are 'master', 'foo', '1.4', '1.5', 'master-1976-01-07', etc."
    exit 1
fi

THIS_DIR="$(cd "$(dirname "$0")" && pwd)"

# Get installation prefix
: ${FENICS_INSTALL_PREFIX:="${HOME}/opt/fenics-dev/${PROFILE}/${FENICS_INSTALL_NAME}"}
echo "Installation prefix set to '${FENICS_INSTALL_PREFIX}'."
export FENICS_INSTALL_PREFIX

# Get branch name
if [ -e .git ]; then
    BRANCH=`(git symbolic-ref --short HEAD 2> /dev/null || git describe HEAD) | sed s:/:.:g`
    echo "On branch '${BRANCH}'."
else
    BRANCH=nobranch
    echo "No branch, no git repository found."
fi

# Get Python executable and version
: ${FENICS_PYTHON_EXECUTABLE:=python}
export FENICS_PYTHON_VERSION=$(${FENICS_PYTHON_EXECUTABLE} -c 'import sys; print(".".join(map(str, sys.version_info[:2])))')
echo "Python executable and version set to '${FENICS_PYTHON_EXECUTABLE} ${FENICS_PYTHON_VERSION}'."

# Get number of processes to use for build
: ${PROCS:=6}

# FIAT might use setuptools now, so we need to make sure the
# site-packages directory exists and update PYTHONPATH
mkdir -p ${FENICS_INSTALL_PREFIX}/lib/python${FENICS_PYTHON_VERSION}/site-packages
export PYTHONPATH=${FENICS_INSTALL_PREFIX}/lib/python${FENICS_PYTHON_VERSION}/site-packages:${PYTHONPATH}

# Build and install distutils based FEniCS package
if [ -e setup.py ]; then
    rm -rf build/
    "${THIS_DIR}/fenics-pip.sh" .
fi

# Build and install CMake based FEniCS package
if [ -e CMakeLists.txt ]; then
    # Set build directory
    if [ "${BRANCH}" = "master" ]; then
        BUILD_DIR=build.${BRANCH}.${FENICS_INSTALL_NAME}
    elif [ "${BRANCH}" = "next" ]; then
        BUILD_DIR=build.${BRANCH}.${FENICS_INSTALL_NAME}
    elif [ "${BRANCH}" = "nobranch" ]; then
        BUILD_DIR=build.${FENICS_INSTALL_NAME}
    else
        # use 'wip' for all other branches to save disk space
        BUILD_DIR=build.wip.${FENICS_INSTALL_NAME}
    fi

    # Generate files that need generating before building (only for DOLFIN)
    if [ ! -d ${BUILD_DIR} -a -f ./cmake/scripts/generate-all ]; then
        yes | ./cmake/scripts/generate-all
    fi

    # Needed to set correct rpath on OS X
    if [ "x$OS" = "xDarwin" ]; then
	CMAKE_EXTRA_ARGS="${CMAKE_EXTRA_ARGS} -DCMAKE_MACOSX_RPATH:BOOL=ON"
    fi

    # Configure
    mkdir -p ${BUILD_DIR}
    cd ${BUILD_DIR}
    time cmake -DCMAKE_INSTALL_PREFIX=${FENICS_INSTALL_PREFIX} \
               -DDOLFIN_ENABLE_TESTING=true \
               -DDOLFIN_ENABLE_BENCHMARKS=true \
               -DCMAKE_BUILD_TYPE=Developer \
               -DDOLFIN_DEPRECATION_ERROR=false \
               -DSWIG_EXECUTABLE=${PROFILE_INSTALL_DIR}/bin/swig \
               ${CMAKE_EXTRA_ARGS} \
               ..

    # Build and install
    time make -j ${PROCS} -k && make install -j ${PROCS}

    # Fix rpath for DOLFIN on OS X
    if [ "x$OS" = "xDarwin" -a -d ./dolfin ]; then
	DEPS_INSTALL_DIR=$(source ${FENICS_INSTALL_PREFIX}/../fenics.deps >/dev/null 2>&1 && echo ${PROFILE_INSTALL_DIR})
	for lib in ${FENICS_INSTALL_PREFIX}/lib/python${FENICS_PYTHON_VERSION}/site-packages/dolfin/cpp/_*.so; do
	    if [ -e ${lib} ]; then
		install_name_tool -add_rpath ${DEPS_INSTALL_DIR}/lib/vtk-5.10 ${lib}
	    fi
	done
    fi
fi

# Write config file
CONFIG_FILE="${FENICS_INSTALL_PREFIX}/fenics.conf"
rm -f ${CONFIG_FILE}
cat << EOF > ${CONFIG_FILE}
# FEniCS configuration file created on $(date)
export FENICS_INSTALL_NAME=${FENICS_INSTALL_NAME}
export FENICS_INSTALL_PREFIX=${FENICS_INSTALL_PREFIX}
export FENICS_PYTHON_EXECUTABLE=${FENICS_PYTHON_EXECUTABLE}
export FENICS_PYTHON_VERSION=${FENICS_PYTHON_VERSION}

# Source FEniCS dependencies if found in parent directory
FENICS_DEPS_CONF=\${FENICS_INSTALL_PREFIX}/../fenics.deps
if [ -e \${FENICS_DEPS_CONF} ]; then
    source \${FENICS_DEPS_CONF}
fi

# Common Unix variables
export LD_LIBRARY_PATH=\${FENICS_INSTALL_PREFIX}/lib:\${LD_LIBRARY_PATH}
export CPLUS_INCLUDE_PATH=\${FENICS_INSTALL_PREFIX}/include:\${CPLUS_INCLUDE_PATH}
export PATH=\${FENICS_INSTALL_PREFIX}/bin:\${PATH}
export PKG_CONFIG_PATH=\${FENICS_INSTALL_PREFIX}/lib/pkgconfig:\${PKG_CONFIG_PATH}
export PYTHONPATH=\${FENICS_INSTALL_PREFIX}/lib/python${FENICS_PYTHON_VERSION}/site-packages:\${PYTHONPATH}
export MANPATH=\${FENICS_INSTALL_PREFIX}/share/man:\${MANPATH}

# Set Instant cache modules separately for each install
export INSTANT_CACHE_DIR=\${FENICS_INSTALL_PREFIX}/cache/instant

# CMake search path
export CMAKE_PREFIX_PATH=\${FENICS_INSTALL_PREFIX}:\${CMAKE_PREFIX_PATH}
EOF
if [ $(uname) = "Darwin" ]; then
    cat << EOF >> $CONFIG_FILE

# Mac specific path
export DYLD_FALLBACK_LIBRARY_PATH=\${FENICS_INSTALL_PREFIX}/lib:\${DYLD_FALLBACK_LIBRARY_PATH}
EOF
fi

# Append alias to alias file
: ${FENICS_ALIAS_FILE:="${HOME}/.fenics_dev_aliases"}
echo "Writing alias to ${FENICS_ALIAS_FILE}."
echo "alias fenics-${FENICS_INSTALL_NAME}='source ${CONFIG_FILE}'" >> ${FENICS_ALIAS_FILE}
sort -u ${FENICS_ALIAS_FILE} -o ${FENICS_ALIAS_FILE}

# Print information
echo
echo "- Installed '${FENICS_INSTALL_NAME}' to ${FENICS_INSTALL_PREFIX}."
echo
echo "- Config file written to ${CONFIG_FILE}"
echo "  (source this file)."
echo
echo "- Add the following alias to your .bash_aliases for easy access:"
echo
echo "  alias fenics-${FENICS_INSTALL_NAME}='source ${CONFIG_FILE}'"
echo
echo "- For convenience, this alias has been appended to ${FENICS_ALIAS_FILE}."
echo "  Consider sourcing this file in your .bashrc or .profile."
echo
