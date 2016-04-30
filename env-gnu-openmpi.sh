#!/bin/bash

source env-gnu.sh

export MY_MPI_PREFIX="${MY_PREFIX}/openmpi"
export MPI_BASE_DIR=${HOME}/local/gnu/openmpi
export MPICC=${HOME}/local/gnu/openmpi/bin/mpicc
export MPIFC=${HOME}/local/gnu/openmpi/bin/mpif90

