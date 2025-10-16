#!/bin/bash

export FC=ifort
export FINALDIR=`pwd`

if [ "$FC" = "ifort"  ] || [ "$FC" = "ifx" ] ; then
  if [ "$OSTYPE" = "Linux" ] ; then
    export start_sh="$(ps -p "$$" -o  command= | awk '{print $1}')" ;
    # ifort config scripts wont work with /bin/sh
    # so we restart using bash
    if [ "$start_sh" = "/bin/sh" ] ; then
      cd ..
      /bin/bash $0 $ARGS
      exit $?
    fi
  fi

  # different releases put setup script in different places
  if [ -x /opt/intel/setvars.sh ] ; then
    . /opt/intel/setvars.sh
  elif [ -d /opt/intel/oneapi ] ; then
    . /opt/intel/oneapi/setvars.sh
  elif [ -d /opt/intel/bin ] ; then
    . /opt/intel/bin/compilervars.sh intel64
  fi

  which ${FC} > /dev/null 2>&1
  if [ $? != 0 ] ; then
    echo ${FC} compiler requested, but not found
    exit 1
  fi
fi

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
