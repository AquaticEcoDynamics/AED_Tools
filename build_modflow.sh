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
cd ${CURDIR}/make
#if [ "$WITH_AED_PLUS" = "true" ] ; then
#  ${MAKE} -f makefile WITH_AED_PLUS=1  AEDWATDIR=$DAEDWATDIR \
#                 AEDBENDIR=$DAEDBENDIR AEDDMODIR=$DAEDDMODIR \
#                 AEDRIPDIR=$DAEDRIPDIR AEDLGTDIR=$DAEDLGTDIR \
#                 AEDDEVDIR=$DAEDDEVDIR PHREEQDIR=$PHREEQDIR \
#                 AEDAPIDIR=$DAEDAPIDIR || exit 1
#else
#  ${MAKE} -f makefile WITH_AED_PLUS=0  AEDWATDIR=$DAEDWATDIR \
#                 AEDBENDIR=$DAEDBENDIR AEDDMODIR=$DAEDDMODIR \
#                 AEDAPIDIR=$DAEDAPIDIR || exit 1
#fi
make

cd ${CURDIR}

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
cp bin/mf6 ${BINPATH}/

exit 0
