#!/bin/bash

source $HOME/.fenics_aliases

FENICS_SOURCE=$HOME/dev/fenics-dev
mkdir -p ${FENICS_SOURCE}
cd ${FENICS_SOURCE}

# Clone all branches
for p in dijitso instant FIAT ufl ffc dolfin; do
    git clone git@bitbucket.org:fenics-project/${p}.git;
done

# Checkout next in all
for p in dijitso instant FIAT ufl ffc dolfin; do
    (cd $p && git checkout -b next origin/next && git checkout master);
done

# Install python packages
for p in dijitso instant FIAT ufl ffc; do
    (cd $p && pip install .);
done

# Show how to build dolfin (not tested)
# (there are so many variations, therefore not automated here)
cd ${FENICS_SOURCE}/dolfin
echo To build dolfin:
echo cd ${FENICS_SOURCE}/dolfin
echo mkdir build
echo cd build
echo cmake .. -DDOLFIN_ENABLE_TRILINOS=OFF -DDOLFIN_ENABLE_VTK=OFF -DDOLFIN_ENABLE_TESTING=ON -DDOLFIN_ENABLE_BENCHMARKS=ON -DCMAKE_INSTALL_PREFIX=$VIRTUAL_ENV -DPYTHON_EXECUTABLE=$VIRTUAL_ENV/bin/python
echo make -j4
echo make install
