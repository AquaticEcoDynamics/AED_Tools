#!/bin/sh

if [ ! -d ELCOM ] ; then
  echo "no ELCOM directory"
  exit 1
fi

CWD=`pwd`
CURDIR=${CWD}/ELCOM

export DEBUG=false

export FC=gfortran
export CC=gcc
export MAKE=make

ARGS=""
while [ $# -gt 0 ] ; do
  ARGS="$ARGS $1"
  case $1 in
    --check)
      export WITH_CHECKS=true
      ;;
    --debug)
      export DEBUG=true
      ;;
    --fence)
      export FENCE=true
      ;;
    --ifx)
      export FC=ifx
      ;;
    --ifort)
      export FC=ifort
      ;;
    --gfortran)
      export FC=gfortran
      ;;
    --flang)
      export FC=flang
      ;;
    *)
      echo unknown arg \"$1\" ignored
      ;;
  esac
  shift
done

. ${CWD}/build_env.inc

export F77=$FC
export F90=$FC
export F95=$FC

export HDF5LIB=$NETCDFHOME/lib
#export HDF5LIBNAME="-lhdf5"

export NETCDFINC=$NETCDFHOME/include
export NETCDFINCL=${NETCDFINC}
export NETCDFLIBDIR=$NETCDFHOME/lib
export NETCDFLIB=${NETCDFLIBDIR}
if [ "$OSTYPE" = "Darwin" ] ; then
  if [ "${HOMEBREW}" = "true" ] ; then
    export NETCDFLIBNAME="-lnetcdff -L/opt/homebrew/lib -lnetcdf"
  else
    export NETCDFLIBNAME="-lnetcdff -L/opt/local/lib -lnetcdf"
  fi
else
  # force the link to use the static version of the netcdff library to avoid
  #  runtime confusion with gfortran version
  export NETCDFLIBNAME="-Xlinker -l:libnetcdff.a -lnetcdf"
fi

#===============================================================================

#if [ "$WITH_AED" = "ON" ] ; then
  . ${CWD}/build_aedlibs.inc
#fi

#===============================================================================

export LIB_PRE=lib
if [ "$OSTYPE" = "Msys" ] ; then
  export LIB_EXT=a
else
  export LIB_EXT=so
fi
export INCLUDES="-I${NETCDFINCL}"
export BUILDDATE=`date -u +%Y%m%d-%H%MUTC`

PARAMS=""

echo build elcom_aed
cd ${CURDIR}/elcom_aed
${MAKE} -f Makefile || exit 1
DELCAEDDIR=`pwd`
PARAMS="${PARAMS} ELCAEDDIR=${DELCAEDDIR}"

echo build cwr_utils
cd ${CURDIR}/cwr_utils
${MAKE} -f Makefile || exit 1
DCWRUTLSDIR=`pwd`
PARAMS="${PARAMS} CWRUTLSDIR=${DCWRUTLSDIR}"

echo build libcwrcommon
cd ${CURDIR}/libcwrcommon
${MAKE} -f Makefile || exit 1
DCWRCMMNDIR=`pwd`
PARAMS="${PARAMS} CWRCMMNDIR=${DCWRCMMNDIR}"

echo build caedym_utils
cd ${CURDIR}/caedym_utils
${MAKE} -f Makefile || exit 1
DCAEDYMUDIR=`pwd`
PARAMS="${PARAMS} CAEDYMUDIR=${DCAEDYMUDIR}"

echo build caedym_src
cd ${CURDIR}/caedym_src
${MAKE} -f Makefile || exit 1
DCAEDYMDIR=`pwd`
PARAMS="${PARAMS} CAEDYMDIR=${DCAEDYMDIR}"

echo build caedym_src_v4
cd ${CURDIR}/caedym_src_v4
${MAKE} -f Makefile || exit 1
DCAEDYM4DIR=`pwd`
PARAMS="${PARAMS} CAEDYM4DIR=${DCAEDYM4DIR}"

if [ -x ${CURDIR}/external/FoX-4.1.2/FoX-config ] ; then
  echo FoX already built
else
  echo build FoX
  cd ${CURDIR}/external/FoX-4.1.2
  ./configure
  ${MAKE} -f Makefile || exit 1
fi

echo build elcom_utils
cd ${CURDIR}/elcom_utils
${MAKE} -f Makefile || exit 1
DECLUTLDIR=`pwd`
PARAMS="${PARAMS} ECLUTLDIR=${ECLUTLDIR}"

echo build elcom_src_v3
cd ${CURDIR}/elcom_src_v3
${MAKE} -f Makefile || exit 1

echo build pre_elcom
cd ${CURDIR}/utilities/pre_elcom
${MAKE} -f Makefile || exit 1


#============================ Linux ===================================
if [ "$OSTYPE" = "Linux" ] ; then
  if [ $(lsb_release -is) = Ubuntu ] ; then
    BINPATH=../binaries/ubuntu/$(lsb_release -rs)
  else
    BINPATH=../binaries/RedHat/$(lsb_release -rs)
  fi
fi
#============================ MacOS ===================================
if [ "$OSTYPE" = "Darwin" ] ; then
  MOSLINE=`grep 'SOFTWARE LICENSE AGREEMENT FOR ' '/System/Library/CoreServices/Setup Assistant.app/Contents/Resources/en.lproj/OSXSoftwareLicense.rtf'`
  MOSNAME=`echo ${MOSLINE} | awk -F 'macOS ' '{print $NF}'  | tr -d '\\' | tr ' ' '_'`

  BINPATH="../binaries/macos/${MOSNAME}"
fi
#============================ Msys ===================================
if [ "$OSTYPE" = "Msys" ] ; then
  BINPATH="../binaries/windows"
fi
#============================= All ====================================


ISODATE=`date +%Y%m%d`
EXTN="_$ISODATE"

cd ${CURDIR}

echo Installing in ${BINPATH}

if [ ! -d ${BINPATH} ] ; then
   mkdir -p ${BINPATH}
fi
cp elcom_src_v3/elcd ${BINPATH}/elcd${EXTN}
cp utilities/pre_elcom/pre_elcom ${BINPATH}/pre_elcom${EXTN}
if [ "$DEBUG" = "true" ] ; then
  ln -fs elcd${EXTN} ${BINPATH}/elcd_latest_d
else
  ln -fs elcd${EXTN} ${BINPATH}/elcd_latest
fi

exit 0
