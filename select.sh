#!/bin/bash

COMPILER="gnu"
if [ x${1} != x ]; then
    COMPILER=${1}
fi

MPI_PROG=""
if [ x${2} != x ]; then
    MPI_PROG=${2}
fi

BUILD_ENV="env-${COMPILER}"
if [ x${MPI_PROG} != x ]; then
    BUILD_ENV="${BUILD_ENV}-${MPI_PROG}"
fi

ln -sf ${BUILD_ENV}.sh env.sh

