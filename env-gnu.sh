#!/bin/bash

SRCDIR=./archives
WORKDIR=./build
MY_PREFIX=${HOME}/local/gnu

export CC=gcc
export CFLAGS="-fopenmp"
export CXX=g++
export CXXFLAGS="${CFLAGS}"
export FC=gfortran
export FCFLAGS="-fopenmp"
export OMPOPT="-fopenmp"

export OPENBLAS_TARGET="SANDYBRIDGE"

USE_OPENBLAS=yes

if [ x${USE_OPENBLAS} = xyes ]; then
    export BLAS_LIBRARIES="${HOME}/local/gnu/lib/libopenblas.a"
    export LAPACK_LIBRARIES="${HOME}/local/gnu/lib/libopenblas.a"
else
    export BLAS_LIBRARIES=${HOME}/local/gnu/lib/libblas.a
    export LAPACK_LIBRARIES=${HOME}/local/gnu/lib/liblapack.a
fi



