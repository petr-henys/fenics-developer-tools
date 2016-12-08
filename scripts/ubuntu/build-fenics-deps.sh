#!/bin/bash
set -e

export TARDIR=$HOME/opt/libs/${DATE}-tars

# Download sources here
mkdir -p $TARDIR
cd $TARDIR
rm -f petsc-lite-${PETSC_VERSION}.tar.gz
rm -f slepc-${SLEPC_VERSION}.tar.gz
wget -nc http://ftp.mcs.anl.gov/pub/petsc/release-snapshots/petsc-lite-${PETSC_VERSION}.tar.gz
wget -nc https://bitbucket.org/slepc/slepc/get/v${SLEPC_VERSION}.tar.gz -O slepc-${SLEPC_VERSION}.tar.gz

#for py in 2 3; do
for py in 3; do

export PREFIX=$HOME/opt/libs/${DATE}-py${py}
export PYTHON=python${py}

echo Using prefix:
echo $PREFIX

# Unpack sources here for building
export SRCDIR=$PREFIX/src
mkdir -p $SRCDIR

# Install PETSc from source
cd $SRCDIR
tar -xf $TARDIR/petsc-lite-${PETSC_VERSION}.tar.gz
cd petsc-${PETSC_VERSION}
python2 ./configure --COPTFLAGS="-O2" \
            --CXXOPTFLAGS="-O2" \
            --FOPTFLAGS="-O2" \
            --with-blas-lib=/usr/lib/libopenblas.a \
            --with-lapack-lib=/usr/lib/liblapack.a \
            --with-c-support \
            --with-debugging=0 \
            --with-shared-libraries \
            --download-suitesparse \
            --download-scalapack \
            --download-metis \
            --download-parmetis \
            --download-ptscotch \
            --download-hypre \
            --download-mumps \
            --download-blacs \
            --download-spai \
            --download-ml \
            --prefix=$PREFIX
make
make install

# Install SLEPc from source
export PETSC_DIR=$PREFIX
cd $SRCDIR
mkdir -p slepc-${SLEPC_VERSION} && tar -xf ${TARDIR}/slepc-${SLEPC_VERSION}.tar.gz -C slepc-${SLEPC_VERSION} --strip-components 1
cd slepc-${SLEPC_VERSION}
python2 ./configure --prefix=$PREFIX
make
make install

# Create virtualenv under prefix with access to system wide packages
$PYTHON -m virtualenv -p $PYTHON --system-site-packages $PREFIX

# Create virtualenv under prefix without access to system wide packages
#$PYTHON -m virtualenv -p $PYTHON $PREFIX

export PETSC_DIR=$PREFIX
export SLEPC_DIR=$PREFIX

source $PREFIX/bin/activate
echo alias dev="source $PREFIX/bin/activate" >> ~/.fenics_aliases
echo "export PETSC_DIR=$PETSC_DIR" >> ~/.fenics_aliases
echo "export SLEPC_DIR=$PETSC_DIR" >> ~/.fenics_aliases

# Upgrade pip
$PYTHON -m pip install --upgrade pip
$PYTHON -m pip install --upgrade setuptools

# Install various packages in virtualenv (jupyter and pytest complains a lot if not inside an env)
$PYTHON -m pip install six pytest pytest-cov pytest-xdist nose sympy jupyter ipdb

# Only in python 2
if (( ${py} == 2 )); then
    $PYTHON -m pip install subprocess32
fi

# Install mpi4py, petsc4py and slepc4py from source in virtualenv
$PYTHON -m pip install --no-cache-dir https://bitbucket.org/mpi4py/mpi4py/downloads/mpi4py-${MPI4PY_VERSION}.tar.gz
$PYTHON -m pip install --no-cache-dir https://bitbucket.org/petsc/petsc4py/downloads/petsc4py-${PETSC4PY_VERSION}.tar.gz
$PYTHON -m pip install --no-cache-dir https://bitbucket.org/slepc/slepc4py/downloads/slepc4py-${SLEPC4PY_VERSION}.tar.gz

done
