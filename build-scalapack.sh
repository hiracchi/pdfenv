#!/bin/bash

source build-common.sh

SCALAPACK_VER="2.0.2"

download()
{
    if [ ! -f "${SRCDIR}/scalapack-${SCALAPACK_VER}.tgz" ]; then
        wget -O "${SRCDIR}/scalapack-${SCALAPACK_VER}.tgz" \
             "http://www.netlib.org/scalapack/scalapack-${SCALAPACK_VER}.tgz"
    fi
}

build()
{
    if [ ! -d ${WORKDIR}/scalapack-${SCALAPACK_VER} ]; then
        tar zxv -C ${WORKDIR} -f "${SRCDIR}/scalapack-${SCALAPACK_VER}.tgz"
    fi

    cd ${WORKDIR}/scalapack-${SCALAPACK_VER}
    make clean
    if [ -f CMakeCache.txt ]; then
        rm CMakeCache.txt
    fi
    cmake -DCMAKE_INSTALL_PREFIX="${MY_MPI_PREFIX}" \
          -DCMAKE_C_COMPILER="${CC}" \
          -DCMAKE_C_FLAGS="${CFLAGS}" \
          -DCMAKE_Fortran_COMPILER="${FC}" \
          -DCMAKE_Fortran_FLAGS="${FCFLAGS}" \
          -DMPI_BASE_DIR="${MY_MPI_PREFIX}" \
          -DMPI_C_LIBRARIES="${MY_MPI_PREFIX}"/lib \
          -DMPI_C_INCLUDE_PATH="${MY_MPI_PREFIX}"/include \
          -DMPI_Fortran_LIBRARIES="${MY_MPI_PREFIX}"/lib \
          -DMPI_Fortran_INCLUDE_PATH="${MY_MPI_PREFIX}"/include \
          -DUSE_OPTIMIZED_LAPACK_BLAS=1 \
          -DBLAS_LIBRARIES="${BLAS_LIBRARIES}" \
          -DLAPACK_LIBRARIES="${LAPACK_LIBRARIES}" \
          . 2>&1 | tee out.cmake

    make ${MAKE_ARGS_PARALLEL} 2>&1 | tee out.make
    make install 2>&1 | tee out.make_install
}

# MAIN
download
build

