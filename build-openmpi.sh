#!/bin/bash

source build-common.sh

OPENMPI_VER="1.10.5"
CONFIG_OPT="\
 --prefix=${MY_MPI_PREFIX}-${OPENMPI_VER} \
 --disable-mpirun-prefix-by-default \
 --disable-orterun-prefix-by-default \
 --enable-mpi-thread-multiple \
 --without-openib \
 --with-cuda=no --disable-opencl \
"
# --without-memory-manager
# --enable-static --disable-shared --disable-dlopen

download()
{
    if [ ! -f "${SRCDIR}/openmpi-${OPENMPI_VER}.tar.bz2" ]; then
        wget -O "${SRCDIR}/openmpi-${OPENMPI_VER}.tar.bz2" \
             "https://www.open-mpi.org/software/ompi/v1.10/downloads/openmpi-${OPENMPI_VER}.tar.bz2"
    fi
}

build()
{
    if [ ! -d ${WORKDIR}/openmpi-${OPENMPI_VER} ]; then
        tar xvj -C "${WORKDIR}" -f "${SRCDIR}/openmpi-${OPENMPI_VER}.tar.bz2"
    fi

    cd ${WORKDIR}/openmpi-${OPENMPI_VER}
    if [ ! -d build ]; then
        mkdir build
    fi

    cd build
    ../configure ${CONFIG_OPT} 2>&1 | tee out.configure

    make clean
    make ${MAKE_ARGS_PARALLEL} 2>&1 | tee out.make
    make install 2>&1 | tee out.make_install
}

link()
{
    if [ -d ${MY_MPI_PREFIX} ]; then
        rm -rf ${MY_MPI_PREFIX}
    fi
    ln -sf ${MY_MPI_PREFIX}-${OPENMPI_VER} ${MY_MPI_PREFIX}
}

# MAIN
download
build
link
