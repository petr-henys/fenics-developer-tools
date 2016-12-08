#!/bin/bash
set -e

if [ "x${FENICS_INSTALL_PREFIX}" = "x" ]; then
    echo 'Please set $FENICS_INSTALL_PREFIX to your installation prefix.'
    exit -1
else
    PIP="${FENICS_PYTHON_EXECUTABLE:=python} -m pip"
    while [ ! -e setup.py ]; do
        cd ..
        if [ `pwd` = '/' ]; then
            echo Found no setup.py in parent paths!
            exit -1
        fi
    done
    $PIP install \
             --no-deps --upgrade \
             --cache-dir="${FENICS_INSTALL_PREFIX}/pipcache" \
             --install-option="--prefix=${FENICS_INSTALL_PREFIX}" \
             .
fi
