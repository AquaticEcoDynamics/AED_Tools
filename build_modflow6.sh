#!/bin/sh

# CWD should be the tools directory in which CURDIR lives
export CWD=`pwd`
# CURDIR should be the directory of the project we are building
export CURDIR=${CWD}/modflow6

if [ ! -d modflow6 ] ; then
  echo "no modflow6 directory"
  exit 1
fi

export DEBUG=false

export FC=gfortran
export CC=gcc
export MAKE=make

export WITH_AED=false
export WITH_AED_PLUS=false

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
    --with-aed)
      export WITH_AED=true
      ;;
    --without-aed)
      export WITH_AED=false
      ;;
    --with-aed-plus)
      export WITH_AED=true
      export WITH_AED_PLUS=true
      ;;
    --without-aed-plus)
      export WITH_AED=false
      export WITH_AED_PLUS=false
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

which meson > /dev/null 2>&1
if [ $? -ne 0 ] ; then
  echo "you will need to have 'meson' installed to compile modflow6"
  exit 1
fi

#-------------------------------------------------------------------------------

export F77=$FC
export F90=$FC
export F95=$FC

. ${CWD}/build_env.inc

#-------------------------------------------------------------------------------

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

if [ "$WITH_AED" = "true" ] ; then
  . ${CWD}/build_aedlibs.inc
fi

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

echo build modflow

cd ${CURDIR}

meson setup build --buildtype="release" --prefix="$HOME/tmp"
meson compile -C build

cd ${CURDIR}

#============================ Linux ===================================
if [ "$OSTYPE" = "Linux" ] ; then
  RELEASE=`lsb_release -is | tr '[A-Z]' '[a-z]'`
  if [ $RELEASE = ubuntu ] || [ $RELEASE = debian ] ; then
    BINPATH=../binaries/$(RELEASE}/$(lsb_release -rs)
  else
    BINPATH=../binaries/redhat/$(lsb_release -rs)
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
if [ -d ${BINPATH}/modflow_latest ] ; then
  /bin/rm -rf ${BINPATH}/modflow_latest
fi
mkdir ${BINPATH}/modflow_latest
mkdir ${BINPATH}/modflow_latest/bin
mkdir ${BINPATH}/modflow_latest/lib

cp build/src/mf6 ${BINPATH}/modflow_latest/bin
cp build/srcbmi/libmf6.so ${BINPATH}/modflow_latest/lib

cd ${BINPATH}
tar czf modflow.tar.gz modflow_latest

exit 0
