#!/bin/bash

cd libfvaed2
. FV_CONFIG
cd ..

while [ $# -gt 0 ] ; do
  case $1 in
    --debug)
      export DEBUG=true
      ;;
    --fence)
      export FENCE=true
      ;;
    --single)
      export SINGLE=true
      ;;
    *)
      ;;
  esac
  shift
done

if [ "$FC" = "" ] ; then
  export FC=ifort
fi

if [ "$FC" = "ifort" ] ; then
  if [ -d /opt/intel/bin ] ; then
    . /opt/intel/bin/compilervars.sh intel64
  fi
  which ifort >& /dev/null
  if [ $? != 0 ] ; then
    echo ifort compiler requested, but not found
    exit 1
  fi
fi

if [ "$SINGLE" = "" ] ; then
  export SINGLE=false
fi
if [ "$PRECISION" = "" ] ; then
  export PRECISION=1
fi
if [ "$PLOTS" = "" ] ; then
  export PLOTS=false
fi
if [ "$EXTERNAL_LIBS" = "" ] ; then
  export EXTERNAL_LIBS=shared
fi
if [ "$DEBUG" = "" ] ; then
  export DEBUG=false
fi

export LICENSE=0

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

export OSTYPE=`uname -s`

if [ "$OSTYPE" == "Linux" ] ; then
  if [ $(lsb_release -is) = Ubuntu ] ; then
    T=_u
  else
    T=_r
  fi
fi
EXTN="_$ISODATE$T$S$D"
cd ${CURDIR}/..
if [ ! -d binaries ] ; then
  mkdir binaries
fi
if [ "$EXTERNAL_LIBS" = "shared" ] ; then
  if [ "$OSTYPE" == "Darwin" ] ; then
    cp libfvaed2/lib/libtuflowfv_external_wq.dylib   binaries/
  fi
  if [ "$OSTYPE" == "Linux" ] ; then
    cp libfvaed2/lib/libtuflowfv_external_wq.so      binaries/
  fi
fi

exit 0
