#!/bin/bash

source build-common.sh

checkout()
{
    if [ ! -d "${WORKDIR}/OpenBLAS" ]; then
        git clone git://github.com/xianyi/OpenBLAS.git ${WORKDIR}/OpenBLAS
    else
        (cd ${WORKDIR}/OpenBLAS; git pull)
    fi
}


build()
{
    # MAKE_ARGS="BINARY=64 INTERFACE64=1 USE_OPENMP=1 NO_LAPACK=1"
    MAKE_ARGS="BINARY=64 INTERFACE64=1 USE_OPENMP=1"
    if [ x${OPENBLAS_TARGET} != x ]; then
        MAkE_ARGS="${MAKE_ARGS} TARGET=\"${OPENBLAS_TARGET}\""
    fi

    cd ${WORKDIR}/OpenBLAS
    make clean

    make ${MAKE_ARGS_PARALLEL} ${MAKE_ARGS} 2>&1 | tee out.make
    make install PREFIX=${MY_PREFIX} 2>&1 | tee out.make_install
}


# MAIN
checkout
build
