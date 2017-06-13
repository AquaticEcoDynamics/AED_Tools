#!/bin/bash

# export DEBUG=true

cd libfvaed2
. FV_CONFIG
cd ..

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
export NETCDFHOME=/opt/intel

export F77=$FC
export F90=$FC
export F95=$FC

export MPI=OPENMPI

export HDF5LIB=$NETCDFHOME/lib
#export HDF5LIBNAME="-lhdf5"

export NETCDFINC=$NETCDFHOME/include
export NETCDFINCL=${NETCDFINC}
export NETCDFLIBDIR=$NETCDFHOME/lib
export NETCDFLIB=${NETCDFLIBDIR}
export NETCDFLIBNAME="-lnetcdff -lnetcdf"

if [ "$DEBUG" = "true" ] ; then
  export COMPILATION_MODE=debug
else
  export COMPILATION_MODE=production
fi


# stop gotm trying to build with fabm
unset FABMDIR
unset FABM
cd ${GOTMDIR}/src
make || exit 1

echo build libaed2
cd  ${CURDIR}/../libaed2
make || exit 1
if [ -d ${CURDIR}/../libaed2-plus ] ; then
  echo build libaed2-plus
  cd  ${CURDIR}/../libaed2-plus
  make || exit 1
fi

if [ "$PLOTS" = "true" ] ; then
  echo build libplot
  cd ${PLOTDIR}
  make || exit 1
fi

echo build tfv_wq
# cd ${FVAED2DIR}
# ./build_tfv_aed.sh || exit 1
make -C ${FVAED2DIR}

echo build tfv
cd ${CURDIR}/../TUFLOWFV/platform/linux_ifort
make || exit 1

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
if [ -f /etc/debian_version ] ; then
  T=_u
else
  T=_r
fi
EXTN="_$ISODATE$T$S$D"
cd ${CURDIR}/..
if [ ! -d binaries ] ; then
  mkdir binaries
fi
cp TUFLOWFV/platform/linux_ifort/tuflowfv binaries/tfv_aed${EXTN}
if [ "$EXTERNAL_LIBS" = "shared" ] ; then
  cp TUFLOWFV/vendor/tuflowfv_external_turb/linux_ifort/libtuflowfv_external_turb.so  binaries/
# cp TUFLOWFV/vendor/tuflowfv_external_wq/linux_ifort/libtuflowfv_external_wq.so      binaries/
  cp libfvaed2/lib/libtuflowfv_external_wq.so      binaries/
  cp TUFLOWFV/vendor/tuflowfv_external_wave/linux_ifort/libtuflowfv_external_wave.so  binaries/
fi

exit 0
