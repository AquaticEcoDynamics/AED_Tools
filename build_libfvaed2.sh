#!/bin/bash

# export DEBUG=true

cd libfvaed2
. FV_CONFIG
cd ..

export EXTERNAL_LIBS=shared

if [ "$DEBUG" = "" ] ; then
  export DEBUG=false
  #export DEBUG=true
fi

if [ "$SINGLE" = "" ] ; then
  export SINGLE=false
  #export SINGLE=true
fi
if [ "$PRECISION" = "" ] ; then
   export PRECISION=1
   #export PRECISION=2
fi
if [ "$PRECISION" = "" ] ; then
  export PLOTS=false
  #export PLOTS=true
fi
if [ "$EXTERNAL_LIBS" = "" ] ; then
  export EXTERNAL_LIBS=static
  #export EXTERNAL_LIBS=shared
fi
export LICENSE=0

source /opt/intel/bin/compilervars.sh intel64

export FORTRAN_COMPILER=IFORT
export FC=ifort

export F77=$FC
export F90=$FC
export F95=$FC

echo build libaed2
cd  ${CURDIR}/../libaed2
make || exit 1
if [ -d ${CURDIR}/../libaed2-plus ] ; then
  echo build libaed2-plus
  cd  ${CURDIR}/../libaed2-plus
  make || exit 1
fi

echo build tfv_wq
make -C ${FVAED2DIR}

ISODATE=`date +%Y%m%d`
if [ "$PRECISION" = "1" ] ; then
   if [ "$SINGLE" = "true" ] ; then
     S='_ss'
   else
     S='_sd'
   fi
else
   S='_dd'
fi
if [ "$DEBUG" = "true" ] ; then
   D='_d'
else
   D=''
fi
if [ $(lsb_release -is) = Ubuntu ] ; then
  T=_u
else
  T=_r
fi
EXTN="_$ISODATE$T$S$D"
cd ${CURDIR}/..
if [ ! -d binaries ] ; then
  mkdir binaries
fi
if [ "$EXTERNAL_LIBS" = "shared" ] ; then
  cp libfvaed2/lib/libtuflowfv_external_wq.so      binaries/
fi

exit 0
