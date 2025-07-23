#!/bin/bash

export FINALDIR=`pwd`

cd ../sources
. ./versions.inc

#export NETCDF=netcdf-c-${NETCDFV}
#export NETCDFF=netcdf-fortran-${NETCDFFV}
#export MPICH=mpich-${MPICHV}
#export OMPI=openmpi-${OMPIV}

# The build_all.sh script accepts :
#   --need-netcdf_c
#   --need-netcdf_f
#   --need-mpich
#   --need-openmpi

./build_all.sh --need-netcdf_f #--need-openmpi

exit 0
