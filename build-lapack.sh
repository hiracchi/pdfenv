#!/bin/bash

source build-common.sh

LAPACK_VER=3.6.0

download()
{
    if [ ! -f "${SRCDIR}/lapack-${LAPACK_VER}.tgz" ]; then
        wget -O "${SRCDIR}/lapack-${LAPACK_VER}.tgz" "http://www.netlib.org/lapack/lapack-${LAPACK_VER}.tgz"
    fi
}


build()
{
    if [ ! -d ${WORKDIR}/lapack-${LAPACK_VER} ]; then
        tar zxv -C "${WORKDIR}" -f "${SRCDIR}/lapack-${LAPACK_VER}.tgz" 
    fi

    cd ${WORKDIR}/lapack-${LAPACK_VER}
    make clean
    if [ -f CMakeCache.txt ]; then
        rm CMakeCache.txt
    fi

    CMAKE_ARGS=""
    if [ x${USE_OPENBLAS} = xyes ]; then
        CMAKE_ARGS="-DUSE_OPTIMIZED_BLAS=1 -DBLAS_LIBRARIES=${BLAS_LIBRARIES}"
    fi
    cmake \
        -DCMAKE_INSTALL_PREFIX=${MY_PREFIX} \
        -DCMAKE_Fortran_COMPILER=${FC} \
        ${CMAKE_ARGS} \
        . 2>&1 | tee out.cmake

    make ${MAKE_ARGS_PARALLEL} 2>&1 | tee out.make 
    make install 2>&1 | tee out.make_install
}


# MAIN
download
build
