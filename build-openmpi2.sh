#!/bin/bash

source build-common.sh

OPENMPI_VER="2.0.1"
CONFIG_OPT="\
 --prefix=${MY_MPI_PREFIX}-${OPENMPI_VER} \
 --enable-static \
 --disable-dlopen \
"

download()
{
    if [ ! -f "${SRCDIR}/openmpi-${OPENMPI_VER}.tar.bz2" ]; then
        wget -O "${SRCDIR}/openmpi-${OPENMPI_VER}.tar.bz2" \
             "https://www.open-mpi.org/software/ompi/v2.0/downloads/openmpi-${OPENMPI_VER}.tar.bz2"
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


