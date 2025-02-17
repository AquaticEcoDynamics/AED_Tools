#!/bin/bash

#export WITH_FABM="ON"
#export WITH_AED="ON"
export FABMDIR=fabm-schism
export WITH_AED_PLUS=false

export CWD=`pwd`
export MAKE=make
export BFLAG='-j8'
export ERROR=0
export MDEBUG=false

# Start by figuring out what system we're on
case `uname` in
  "Darwin"|"Linux"|"FreeBSD")
    export OSTYPE=`uname -s`
    ;;
  MINGW*)
    export OSTYPE="Msys"
    ;;
esac

#-------------------------------------------------------------------------------
# Set up some defaults

if [ "$OSTYPE" = "FreeBSD" ] ; then
  export FC=flang
  export CC=clang
  export MAKE=gmake
else
  export FC=gfortran
  export CC=gcc
  export MAKE=make
fi

# If we're on ubuntu we need to make sure we have :
#
#    libnetcdf-dev and cmake
#
# and if we're using gfortran we need :
#
#    libopenmpi-dev openmpi-bin libnetcdff-dev
#
if [ "$OSTYPE" = "Linux" ] ; then
  dpkg --list cmake > /dev/null 2>& 1
  if [ $? -ne 0 ] ; then
    ERROR=1
    echo 'schism requires cmake installed to build'
  fi
# dpkg --list libnetcdf-dev > /dev/null 2>& 1
# if [ $? -ne 0 ] ; then
#   ERROR=1
#   echo 'schism requires libnetcdf-dev installed to build'
# fi
fi

#
# Also we need python and python3 wont be found so either need a symlink or :
#
#alias python=python3
# but alias doesnt work in "sh", it needs "bash" or "zsh" or ...
# and aliased python also doesnt work within cmake, so have to make a symlink
#

#-------------------------------------------------------------------------------
# Now scan the argument list

ARGS=""
while [ $# -gt 0 ] ; do
  ARGS="$ARGS $1"
  case $1 in
    --debug)
      export DEBUG=true
      ;;
    --mdebug)
      export MDEBUG=true
      ;;
    --fence)
      export FENCE=true
      ;;
    --gfort)
      export FC=gfortran
      ;;
    --ifx)
      export FC=ifx
      ;;
    --ifort)
      export FC=ifort
      ;;
    --flang)
      export FC=flang
      ;;
    --with-aed)
      export WITH_AED="ON"
      ;;
    --with-aed-plus)
      export WITH_AED="ON"
      export WITH_AED_PLUS=true
      ;;
    --with-fabm)
      export WITH_FABM="ON"
      ;;

    --with-no-parmetis)
      export WITH_NO_PARMETIS="ON"
      ;;
    --with-oldio)
      export WITH_OLDIO="ON"
      ;;
    --with-atmos)
      export WITH_ATMOS="ON"
      ;;
    --with-nwm-bmi)
      export WITH_NWM_BMI="ON"
      ;;
    --with-prec-evap)
      export WITH_PREC_EVAP="ON"
      ;;
    --with-bulk-fairall)
      export WITH_BULK_FAIRALL="ON"
      ;;
    --with-gotm)
      export WITH_GOTM="ON"
      ;;
    --with-ha)
      export WITH_HA="ON"
      ;;
    --with-marsh)
      export WITH_MARSH="ON"
      ;;
    --with-pahm)
      export WITH_PAHM="ON"
      ;;
    --with-wwm)
      export WITH_WWM="ON"
      ;;
    --with-ww3)
      export WITH_WW3="ON"
      ;;
    --with-ice)
      export WITH_ICE="ON"
      ;;
    --with-mice)
      export WITH_MICE="ON"
      ;;
    --with-gen)
      export WITH_GEN="ON"
      ;;
    --with-age)
      export WITH_AGE="ON"
      ;;
    --with-eco)
      export WITH_ECO="ON"
      ;;
    --with-icm)
      export WITH_ICM="ON"
      ;;
    --with-cosine)
      export WITH_COSINE="ON"
      ;;
    --with-fib)
      export WITH_FIB="ON"
      ;;
    --with-sed)
      export WITH_SED="ON"
      ;;
    --with-dvd)
      export WITH_DVD="ON"
      ;;
    --with-debug)
      export WITH_DEBUG="ON"
      ;;
    --with-analysis)
      export WITH_ANALYSIS="ON"
      ;;

    --try-mods)
      export WITH_AED="ON"
#     export WITH_FABM="ON"
      export WITH_GOTM="ON"
      export WITH_NO_PARMETIS="ON"
#     export WITH_OLDIO="ON"
      export WITH_ATMOS="ON"
      export WITH_NWM_BMI="ON"
      export WITH_PREC_EVAP="ON"
      export WITH_BULK_FAIRALL="ON"
#     export WITH_HA="ON"
#     export WITH_MARSH="ON"
#     export WITH_PAHM="ON"
#     export WITH_WWM="ON"
#     export WITH_WW3="ON"
      export WITH_ICE="ON"
      export WITH_MICE="ON"
      export WITH_GEN="ON"
      export WITH_AGE="ON"
#     export WITH_ECO="ON"
#     export WITH_ICM="ON"
#     export WITH_COSINE="ON"
      export WITH_FIB="ON"
      export WITH_SED="ON"
      export WITH_DVD="ON"
      export WITH_DEBUG="ON"
      export WITH_ANALYSIS="ON"
      ;;

    --verbose)
      export BFLAG="${BFLAG} VERBOSE=1"
      ;;
    --help)
      echo "build_schism accepts the following flags:"
      echo "  --debug          : build with debugging symbols"
      echo "  --gfort          : use the gfortran compiler"
      echo "  --ifort          : use the older intel fortran compiler"
      echo "  --ifx            : use the newer intel fortran compiler"
#     echo "  --flang          : use the flang compiler"
      echo "  --verbose        : turn on the verbose make flag"
      echo
      echo "  --with-aed       : build with aed enabled (default)"
      echo "  --with-aed-plus  : build with aed and aed-plus enabled"
      echo
      echo "  --with-fabm      : build with fabm enabled"
      echo "  --with-gotm      : fabm and gotm cannot be used together"
      echo
      echo "  --with-prec-evap : Include precipitation and evaporation calculation"
      echo "  --with-cosine    : turn on cosine model                (DOESNT COMPILE)"
      echo "  --with-no-parmetis"
      echo "  --with-oldio"
      echo "  --with-atmos"
      echo "  --with-nwm-bmi"
      echo "  --with-bulk-fairall : Enable Fairall bulk scheme for air-sea exchange"
      echo "  --with-ha        : Enable harmonic analysis output modules (DOESNT COMPILE)"
      echo "  --with-marsh     : Use marsh module                    (DOESNT COMPILE)"
      echo "  --with-pahm      : Use PaHM module                     (DOESNT COMPILE)"
      echo "  --with-wwm       : Use wind-wave module                (DOESNT COMPILE)"
      echo "  --with-ww3       : Use Wave Watch III                  (DOESNT COMPILE)"
      echo "  --with-ice       : Use 1-class ICE module"
      echo "  --with-mice      : Use multi-class ICE module          (DOESNT COMPILE)"
      echo
      echo " #Tracer models:"
      echo "  --with-gen       : Use generic tracer module"
      echo "  --with-age       : Use age module"
      echo "  --with-eco       : Use ECO-SIM module                  (DOESNT COMPILE)"
      echo "  --with-icm       : Use ICM module                      (DOESNT COMPILE)"
      echo "  --with-fib       : Use fecal indicating bacteria module"
      echo "  --with-sed       : Use sediment module"
      echo "  --with-dvd"
      echo
      echo "  --with-debug"
      echo "  --with-analysis"
      echo
      echo "  --try-mods  : turn on all modules"
      echo "                except fabm, oldio and any marked as not compilable"
      echo
      echo " DOESNT COMPILE in most cases seems to be mpi related. It looks like"
      echo " schism using gfortran originally used mpich rather than openmpi and"
      echo " it hasn't been updated."

      exit 0
      ;;
    *)
      echo "Unknown option \"$1\""
      export ERROR=1
      ;;
  esac
  shift
done

#-------------------------------------------------------------------------------

. ${CWD}/build_env.inc

export F77=$FC
export F90=$FC
export F95=$FC

#-------------------------------------------------------------------------------

if [ "$WITH_FABM" = "ON" ] ; then
  if [ ! -d ${FABMDIR} ] ; then
    git clone https://github.com/josephzhang8/fabm.git ${FABMDIR}

    patch -p0 << EOF
diff --git fabm-schism-orig/src/drivers/schism/fabm_driver.h fabm-schism/src/drivers/schism/fabm_driver.h
--- fabm-schism-orig/src/drivers/schism/fabm_driver.h
+++ fabm-schism/src/drivers/schism/fabm_driver.h
@@ -10,4 +10,7 @@
 #define _FABM_VERTICAL_BOTTOM_TO_SURFACE_
 #define _FABM_BOTTOM_INDEX_ -1
 
+#define _FABM_MASK_TYPE_ integer
+#define _FABM_UNMASKED_VALUE_ 1
+
 #include "fabm.h"
EOF
  fi

  cd ${FABMDIR}
  if [ ! -d build ] ; then
    mkdir build
  fi
  cd build
  cmake .. || exit 1
  ${MAKE} || exit 1

  cd ${CWD}
fi

#-------------------------------------------------------------------------------

if [ "$WITH_AED" = "ON" ] ; then
  . ${CWD}/build_aedlibs.inc
fi

#-------------------------------------------------------------------------------
#
# Now configure schism
#
#-------------------------------------------------------------------------------

cd schism

#
# First specify the compiler setup
#
#---------------------------------
if [ "$FC" = "ifort" ] || [ "$FC" = "ifx" ] ; then
  FFLAGS_RELEASE="-O2 -fpp -qoverride-limits -qopenmp-link=static"

  #-------------------------------
  cat << EOF > cmake/SCHISM.local.aed
# what follows is a simple configuration for Ubuntu

set(CMAKE_Fortran_COMPILER ${FC} CACHE PATH "Path to serial Fortran compiler")
set(CMAKE_C_COMPILER gcc CACHE PATH "Path to serial C compiler")
set(CMAKE_Fortran_FLAGS_RELEASE "${FFLAGS_RELEASE}" CACHE STRING "Fortran flags" FORCE)

set(NetCDF_PARALLEL "FALSE")
#
set(NetCDF_DIR "${NETCDFHOME}" CACHE PATH "Default Path to NetCDF")

set(NetCDF_Fortran_DIR "${NCDFFBASE}" CACHE PATH "Path to NetCDF Fortran library")
set(NetCDF_Fortran_CONFIG_EXECUTABLE "${NCDFFBASE}/bin/nf-config" CACHE PATH "Path to NetCDF Fortran Executable")
#set(NetCDF_Fortran_LIBRARY "${NCDFFBASE}/lib -lnetcdff" CACHE PATH "Path to NetCDF Fortran library")
set(NetCDF_Fortran_INCLUDE "${NCDFFBASE}/include" CACHE PATH "Path to NetCDF Fortran Include File")

set(NetCDF_C_DIR "${NCDFCBASE}" CACHE PATH "Path to NetCDF C")
set(NetCDF_C_CONFIG_EXECUTABLE "${NCDFCBASE}/bin/nc-config" CACHE PATH "Path to NetCDF C Executable")
#set(NetCDF_C_LIBRARY "/usr/lib/x86_64-linux-gnu" CACHE PATH "Path to NetCDF C library")
set(NetCDF_C_INCLUDE "/usr/include" CACHE PATH "Path to NetCDF C include file")

# Doesn't seem to get used
#set(MPI_ROOT "${CWD}/ancillary/${FC}"  CACHE PATH "Root dir of MPI")

EOF
#---------------------------------
else
  FFLAGS_RELEASE="-O2 -ffree-line-length-none -static-libgfortran -finit-local-zero"
  if [ "$OSTYPE" = "Darwin" ] ; then
    cp cmake/SCHISM.homebrew.gcc-openmpi cmake/SCHISM.local.aed
  else
    cp cmake/SCHISM.local.ubuntu cmake/SCHISM.local.aed
  fi
fi
#---------------------------------

#-------------------------------------------------------------------------------
# Here is where we turn on/off various modules
#-------------------------------------------------------------------------------
cp cmake/SCHISM.local.build cmake/SCHISM.local.build.aed
echo 'set( USE_AED OFF CACHE BOOLEAN "AED module interface")' >> cmake/SCHISM.local.build.aed

if [ "$WITH_NO_PARMETIS" = "ON" ] ; then
  sed -i -e "s^NO_PARMETIS OFF^NO_PARMETIS ON^" cmake/SCHISM.local.build.aed
fi
if [ "$WITH_OLDIO" = "ON" ] ; then
  sed -i -e "s^OLDIO OFF^OLDIO ON^" cmake/SCHISM.local.build.aed
fi
if [ "$WITH_ATMOS" = "ON" ] ; then
  sed -i -e "s^USE_ATMOS OFF^USE_ATMOS ON^" cmake/SCHISM.local.build.aed
fi
if [ "$WITH_NWM_BMI" = "ON" ] ; then
  sed -i -e "s^USE_NWM_BMI OFF^USE_NWM_BMI ON^" cmake/SCHISM.local.build.aed
fi
if [ "$WITH_PREC_EVAP" = "ON" ] ; then
  sed -i -e "s^PREC_EVAP OFF^PREC_EVAP ON^" cmake/SCHISM.local.build.aed
fi
if [ "$WITH_BULK_FAIRALL" = "ON" ] ; then
  sed -i -e "s^USE_BULK_FAIRALL OFF^USE_BULK_FAIRALL ON^" cmake/SCHISM.local.build.aed
fi
if [ "$WITH_GOTM" = "ON" ] ; then
  sed -i -e "s^USE_GOTM OFF^USE_GOTM ON^" cmake/SCHISM.local.build.aed
# sed -i -e "s^##set( GOTM_BASE /work2/03473/seatonc/frontera/GOTM5.2/code^set( GOTM_BASE ${CWD}/gotm-git^" cmake/SCHISM.local.build.aed
fi
if [ "$WITH_HA" = "ON" ] ; then
  sed -i -e "s^USE_HA OFF^USE_HA ON^" cmake/SCHISM.local.build.aed
fi
if [ "$WITH_MARSH" = "ON" ] ; then
  sed -i -e "s^USE_MARSH OFF^USE_MARSH ON^" cmake/SCHISM.local.build.aed
fi
if [ "$WITH_PAHM" = "ON" ] ; then
  sed -i -e "s^USE_PAHM OFF^USE_PAHM ON^" cmake/SCHISM.local.build.aed
fi
if [ "$WITH_WWM" = "ON" ] ; then
  sed -i -e "s^USE_WWM OFF^USE_WWM ON^" cmake/SCHISM.local.build.aed
fi
if [ "$WITH_WW3" = "ON" ] ; then
  sed -i -e "s^USE_WW3 OFF^USE_WW3 ON^" cmake/SCHISM.local.build.aed
fi
if [ "$WITH_ICE" = "ON" ] ; then
  sed -i -e "s^USE_ICE OFF^USE_ICE ON^" cmake/SCHISM.local.build.aed
fi
if [ "$WITH_MICE" = "ON" ] ; then
  sed -i -e "s^USE_MICE OFF^USE_MICE ON^" cmake/SCHISM.local.build.aed
fi
if [ "$WITH_GEN" = "ON" ] ; then
  sed -i -e "s^USE_GEN OFF^USE_GEN ON^" cmake/SCHISM.local.build.aed
fi
if [ "$WITH_AGE" = "ON" ] ; then
  sed -i -e "s^USE_AGE OFF^USE_AGE ON^" cmake/SCHISM.local.build.aed
fi
if [ "$WITH_ECO" = "ON" ] ; then
  sed -i -e "s^USE_ECO OFF^USE_ECO ON^" cmake/SCHISM.local.build.aed
fi
if [ "$WITH_ICM" = "ON" ] ; then
  sed -i -e "s^USE_ICM OFF^USE_ICM ON^" cmake/SCHISM.local.build.aed
fi
if [ "$WITH_COSINE" = "ON" ] ; then
  sed -i -e "s^USE_COSINE OFF^USE_COSINE ON^" cmake/SCHISM.local.build.aed
fi
if [ "$WITH_FIB" = "ON" ] ; then
  sed -i -e "s^USE_FIB OFF^USE_FIB ON^" cmake/SCHISM.local.build.aed
fi
if [ "$WITH_SED" = "ON" ] ; then
  sed -i -e "s^USE_SED OFF^USE_SED ON^" cmake/SCHISM.local.build.aed
fi

if [ "$WITH_FABM" = "ON" ] ; then
  sed -i -e "s^USE_FABM OFF^USE_FABM ON^" cmake/SCHISM.local.build.aed
  sed -i -e "s^/sciclone/home10/wangzg/fabm^${CWD}/${FABMDIR}^" cmake/SCHISM.local.build.aed
fi
if [ "$WITH_AED" = "ON" ] ; then
  sed -i -e "s^USE_AED OFF^USE_AED ON^" cmake/SCHISM.local.build.aed
# sed -i -e "s^/home/anonymous/libaed-api^${CWD}/libaed-api^" cmake/SCHISM.local.build.aed
# sed -i -e "s^/home/anonymous/libaed-water^${CWD}/libaed-water^" cmake/SCHISM.local.build.aed
 #sed    -e "s^/home/anonymous/libaed-^${CWD}/libaed-^" src/AED/CMakeLists.txt.m > src/AED/CMakeLists.txt
  sed    -e "s^/home/anonymous/lib^${CWD}/lib^" src/AED/CMakeLists.txt.m > src/AED/CMakeLists.txt
fi
if [ "$WITH_DVD" = "ON" ] ; then
  sed -i -e "s^USE_DVD OFF^USE_DVD ON^" cmake/SCHISM.local.build.aed
fi

if [ "$WITH_DEBUG" = "ON" ] ; then
  sed -i -e "s^DEBUG OFF^DEBUG ON^" cmake/SCHISM.local.build.aed
fi
if [ "$WITH_ANALYSIS" = "ON" ] ; then
  sed -i -e "s^USE_ANALYSIS OFF^USE_ANALYSIS ON^" cmake/SCHISM.local.build.aed
fi

#-------------------------------------------------------------------------------
# Here's the actual building stuff
#-------------------------------------------------------------------------------

mkdir build
cd build

if [ "$DEBUG" = "true" ] ; then
  export CFLAGS="$CFLAGS -g"
  export FFLAGS="$FFLAGS -g -fcheck=all,no-array-temps"
  export LDFLAGS="$LDFLAGS -lefence"
fi
if [ "$MDEBUG" = "true" ] ; then
  export CFLAGS="$CFLAGS -g -fsanitize=address"
  export FFLAGS="$FFLAGS -g -fcheck=all,no-array-temps -fsanitize=address"
fi
if [ "${WITH_AED_PLUS}" = "true" ] ;then
  export WITH_AED_PLUS=${WITH_AED_PLUS}
fi

# cmake generates a bunch of developer warnings and says to use -Wno-dev to supress
# them, but adding it here doesn't seem to do anything
cmake -Wno-dev -G "Unix Makefiles" \
      -C ../cmake/SCHISM.local.build.aed \
      -C ../cmake/SCHISM.local.aed ../src/ || exit 1

# On MacOS we have something like (it still didn't work, though) :
#
# export MPI_HOME="${CWD}/ancillary/${FC}"
# export MPIEXEC_EXECUTABLE="${CWD}/ancillary/${FC}/bin/mpiexec"
# export MPI_CXX_COMPILER="${CWD}/ancillary/${FC}/bin/mpicxx"
# export MPI_CXX_HEADER_DIR="${CWD}/ancillary/${FC}/include"
# export MPI_CXX_LIB_NAMES="-Wl,-rpath -Wl,${exec_prefix}/lib -Wl,--enable-new-dtags -L${libdir} -lmpi -lpthread -L${CWD}/ancillary/${FC}/lib -latomic -lpthread -ldl"
# export MPI_C_COMPILER="${CWD}/ancillary/${FC}/bin/mpicc"
# export MPI_C_HEADER_DIR="${CWD}/ancillary/${FC}/include"
# export MPI_C_LIB_NAMES="-Wl,-rpath -Wl,${exec_prefix}/lib -Wl,--enable-new-dtags -L${libdir} -lmpi -lpthread -L${CWD}/ancillary/${FC}/lib -latomic -lpthread -ldl"
# export MPI_Fortran_COMPILER="${CWD}/ancillary/${FC}/bin/mpifort"
# export MPI_Fortran_F77_HEADER_DIR="${CWD}/ancillary/${FC}/include"
# export MPI_Fortran_LIB_NAMES="-Wl,-rpath -Wl,${exec_prefix}/lib -Wl,--enable-new-dtags -L${libdir} -lmpi -lpthread -L${CWD}/ancillary/${FC}/lib -latomic -lpthread -ldl"
#
# cmake -Wno-dev -G "Unix Makefiles" \
#     -DMPI_HOME=${MPI_HOME} \
#     -DMPIEXEC_EXECUTABLE=${MPIEXEC_EXECUTABLE} \
#     -DMPI_CXX_COMPILER=${MPI_CXX_COMPILER} \
#     -DMPI_CXX_HEADER_DIR=${MPI_CXX_HEADER_DIR} \
#     -DMPI_CXX_LIB_NAMES=${MPI_CXX_LIB_NAMES} \
#     -DMPI_C_COMPILER=${MPI_C_COMPILER} \
#     -DMPI_C_HEADER_DIR=${MPI_C_HEADER_DIR} \
#     -DMPI_C_LIB_NAMES=${MPI_C_LIB_NAMES} \
#     -DMPI_Fortran_COMPILER=${MPI_Fortran_COMPILER} \
#     -DMPI_Fortran_HEADER_DIR=${MPI_Fortran_HEADER_DIR} \
#     -DMPI_Fortran_LIB_NAMES=${MPI_Fortran_LIB_NAMES} \
#     -C ../cmake/SCHISM.local.build.aed \
#     -C ../cmake/SCHISM.local.aed ../src/ || exit 1


${MAKE} $BFLAG || exit 1

#-------------------------------------------------------------------------------

ISODATE=`date +%Y%m%d`

#============================ Linux ===================================
if [ "$OSTYPE" = "Linux" ] ; then
  if [ $(lsb_release -is) = Ubuntu ] ; then
    T=_u
  else
    T=_r
  fi
  if [ $(lsb_release -is) = Ubuntu ] ; then
    BINPATH=binaries/ubuntu/$(lsb_release -rs)
  else
    BINPATH=binaries/redhat/$(lsb_release -rs)
  fi
fi
#============================ MacOS ===================================
if [ "$OSTYPE" = "Darwin" ] ; then
  MOSLINE=`grep 'SOFTWARE LICENSE AGREEMENT FOR ' '/System/Library/CoreServices/Setup Assistant.app/Contents/Resources/en.lproj/OSXSoftwareLicense.rtf'`
  MOSNAME=`echo ${MOSLINE} | awk -F 'macOS ' '{print $NF}'  | tr -d '\\' | tr ' ' '_'`

  T="_${MOSNAME}"

  BINPATH="binaries/macos/${MOSNAME}"
fi
#============================ more ===================================


EXTN="_$ISODATE"
cd ${CWD}

if [ ! -d ${BINPATH} ] ; then
   mkdir -p ${BINPATH}
fi
cp schism/build/bin/pschism* ${BINPATH}/

exit 0
