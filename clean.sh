#!/bin/bash

CWD=`pwd`

for i in water benthic riparian demo dev fv ; do
   echo clean libaed-$i
   if [ -d libaed-$i ] ; then
     cd  libaed-$i
     make distclean
     cd ..
   fi
done

if [ -d gotm-git ] ; then
  export GOTMDIR=${CWD}/gotm-git
  export FORTRAN_COMPILER=IFORT
  cd gotm-git
  make distclean
  cd ..
fi

if [ -d tuflowfv-svn ] ; then
  export OSTYPE=`uname -s`
  if [ "${OSTYPE}" = "Linux" ] ; then
    PLATFORM=linux_ifort
  elif [ "${OSTYPE}" = "Darwin" ] ; then
    PLATFORM=macos_ifort
  fi

  cd ${CWD}/tuflowfv-svn/platform/${PLATFORM}
  make clean
  cd ..
fi

if [ -d GLM ] ; then
  cd ${CWD}/GLM
  make distclean
  cd ..
fi

exit 0
