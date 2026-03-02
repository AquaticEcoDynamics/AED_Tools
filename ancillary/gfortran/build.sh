#!/bin/bash

export FINALDIR=`pwd`

cd ../sources
. ./versions.inc

# The build_all.sh script accepts :
#   --need-netcdf_c
#   --need-netcdf_f
#   --need-mpich
#   --need-openmpi

if [ $# != 0 ] ; then
  ./build_all.sh $*
else
  ./build_all.sh --need-netcdf_f #--need-openmpi
fi

exit 0
