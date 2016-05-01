#!/bin/bash

source build-common.sh

MPICH_VER="3.2"
CONFIG_OPT="\
 --prefix=${MY_MPI_PREFIX} \
 --enable-fortran=all \
 --enable-cxx \
 --disable-silent-rules \
 --enable-static \
"

download()
{
    if [ ! -f "${SRCDIR}/mpich-${MPICH_VER}.tar.gz" ]; then
        wget -O "${SRCDIR}/mpich-${MPICH_VER}.tar.gz" \
             "http://www.mpich.org/static/downloads/3.2/mpich-${MPICH_VER}.tar.gz"
    fi
    
    if [ ! -f "${SRCDIR}/hydra-${MPICH_VER}.tar.gz" ]; then
        wget -O "${SRCDIR}/hydra-${MPICH_VER}.tar.gz" \
             "http://www.mpich.org/static/downloads/${MPICH_VER}/hydra-${MPICH_VER}.tar.gz"
    fi
}


build()
{
    if [ ! -d "${WORKDIR}/mpich-${MPICH_VER}" ]; then
        tar xvz -C "${WORKDIR}" -f "${SRCDIR}/mpich-${MPICH_VER}.tar.gz" 
    fi
    if [ ! -d "${WORKDIR}/hydra-${MPICH_VER}" ]; then
        tar xvz -C "${WORKDIR}" -f "${SRCDIR}/hydra-${MPICH_VER}.tar.gz" 
    fi

    # build mpich
    cd ${WORKDIR}/mpich-${MPICH_VER}
    if [ ! -d build ]; then
        mkdir build
    fi

    cd build
    CFLAGS="${CFLAGS} -D_XOPEN_SOURCE=500"
    CXXFLAGS="${CXXFLAGS} -D_XOPEN_SOURCE=500"
    ../configure ${CONFIG_OPT} 2>&1 | tee out.configure

    make 2>&1 | tee out.make
    make install 2>&1 | tee out.make_install
    
    # build hydra
    cd ${WORKDIR}/hydra-${MPICH_VER}
    if [ ! -d build ]; then
        mkdir build
    fi

    cd build
    CFLAGS="${CFLAGS} -D_XOPEN_SOURCE=500"
    CXXFLAGS="${CXXFLAGS} -D_XOPEN_SOURCE=500"
    ../configure ${CONFIG_OPT} 2>&1 | tee out.configure

    make 2>&1 | tee out.make
    make install 2>&1 | tee out.make_install
}

# MAIN
download
build
