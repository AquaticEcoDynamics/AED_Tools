#!/bin/bash

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

export WITHFABM="OFF"
export COSON="OFF"
export PREC_EVAP="OFF"

export CWD=`pwd`
export MAKE=make
export BFLAG='-j8'
export ERROR=0

if [ "$OSTYPE" = "FreeBSD" ] ; then
  export FC=flang
  export CC=clang
  export MAKE=gmake
else
  export FC=gfortran
  export CC=gcc
  export MAKE=make
fi

export FC=ifort
export COSON="ON"
export WITHFABM="ON"

# If we're on ubuntu we need to make sure we have :
#
#    libnetcdf-dev and cmake
#
# and if we're using gfortran we need :
#
#    libopenmpi-dev openmpi-bin netcdff-dev
#
if [ "$OSTYPE" = "Linux" ] ; then
  dpkg --list cmake > /dev/null 2>& 1
  if [ $? -ne 0 ] ; then
    ERROR=1
    echo 'schism requires cmake installed to build'
  fi
  dpkg --list libnetcdf-dev > /dev/null 2>& 1
  if [ $? -ne 0 ] ; then
    ERROR=1
    echo 'schism requires libnetcdf-dev installed to build'
  fi
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
    --fence)
      export FENCE=true
      ;;
    --gfort)
      export FC=gfortran
      ;;
    --ifort)
      export FC=ifort
      ;;
    --flang)
      export FC=flang
      ;;
    --with-fabm)
      export WITHFABM="ON"
      ;;

# set (PREC_EVAP OFF CACHE BOOLEAN "Include precipitation and evaporation calculation")
    --prec-evap-on)
      export PREC_EVAP="ON"
      ;;
# set (USE_BULK_FAIRALL OFF CACHE BOOLEAN "Enable Fairall bulk scheme for air-sea exchange")
# set (IMPOSE_NET_FLUX  OFF CACHE BOOLEAN "Specify net heat and salt fluxes in sflux")
# ##Older versions of GOTM (3.*) have issues with netcdf v4, so are not maintained
# set (USE_GOTM OFF CACHE BOOLEAN \
#     "Use GOTM turbulence model. This just enables the build -- GOTM must still be selected in param.nml")
# set (USE_HA OFF CACHE BOOLEAN "Enable harmonic analysis output modules")
# set( USE_MARSH OFF CACHE BOOLEAN "Use marsh module")
# set( USE_PAHM OFF CACHE BOOLEAN "Use PaHM module")
#
# #   Enable/Disable Modules
# set( USE_SED2D OFF CACHE BOOLEAN "Use 2D sediment module")
# set( USE_WWM OFF CACHE BOOLEAN "Use wind-wave module")
# ##Coupling to WW3, either via ESMF or hard coupling (in dev)
# set( USE_WW3 OFF CACHE BOOLEAN "Use Wave Watch III")
# set( USE_ICE OFF CACHE BOOLEAN "Use 1-class ICE module")
# set( USE_MICE OFF CACHE BOOLEAN "Use multi-class ICE module")
#
# #Tracer models
# set( USE_GEN OFF CACHE BOOLEAN "Use generic tracer module")
# set( USE_AGE OFF CACHE BOOLEAN "Use age module")
# set( USE_ECO OFF   CACHE BOOLEAN "Use ECO-SIM module")
# set( USE_ICM OFF  CACHE BOOLEAN "Use ICM module")

    --try-mods)
      export COSON="ON"
      ;;
    --cosine-on)
      export COSON="ON"
      ;;

# set( USE_FIB OFF   CACHE BOOLEAN "Use fecal indicating bacteria module")
# set( USE_SED OFF   CACHE BOOLEAN "Use sediment module")

    --verbose)
      export BFLAG="${BFLAG} VERBOSE=1"
      ;;
    *)
      echo "Unknown option \"$1\""
      export ERROR=1
      ;;
  esac
  shift
done

#-------------------------------------------------------------------------------
export NETCDF_C_HOME=/usr

if [ "$FC" = "ifort" ] ; then
  if [ "$OSTYPE" = "Linux" ] ; then
    export start_sh="$(ps -p "$$" -o  command= | awk '{print $1}')" ;
    # ifort config scripts wont work with /bin/sh
    # so we restart using bash
    if [ "$start_sh" = "/bin/sh" ] ; then
      /bin/bash $0 $ARGS
      exit $?
    fi
  fi

# this seems to work on the link stage to make linking look in these directories
# before the default (/usr/lib ) specifically to solve MPI problem.
# Sadly, the include part doesn't work because the compile stage puts this after
#  something that specifies /usr/include which stuffs up netcdf if we also have
#  the gfortran version installed
# export FFLAGS="-I/opt/intel/include"
  export LDFLAGS="-L/opt/intel/lib -L/opt/intel/oneapi/mpi/latest/lib -L/opt/intel/oneapi/mpi/latest/lib/release"

  if [ -x /opt/intel/setvars.sh ] ; then
    . /opt/intel/setvars.sh
  elif [ -d /opt/intel/oneapi ] ; then
    . /opt/intel/oneapi/setvars.sh
  else
    if [ -d /opt/intel/bin ] ; then
       . /opt/intel/bin/compilervars.sh intel64
    fi
  fi
  which ifort > /dev/null 2>&1
  if [ $? != 0 ] ; then
     echo ifort compiler requested, but not found
     exit 1
  fi
  IFORT_PATH=`which ifort`

# export NETCDF_HOME=/opt/intel
  export NETCDF_FORTRAN_HOME=/opt/intel
  export FCB=ifort

  dpkg --list libnetcdff-dev > /dev/null 2>& 1
  if [ $? -eq 0 ] ; then
    ERROR=1
    echo 'schism cannot have libnetcdff-dev installed if using intel fortran'
  fi
elif [ "$FC" = "gfortran" ] ; then
  export NETCDF_FORTRAN_HOME=/usr
  export FCB=gfortran
else
  export NETCDF_FORTRAN_HOME=/usr
  export FCB=gfortran
fi
if [ "$FC" = "gfortran" ] ; then
  dpkg --list openmpi-bin > /dev/null 2>& 1
  if [ $? -ne 0 ] ; then
    ERROR=1
    echo 'schism requires openmpi-bin installed to build'
  fi
  dpkg --list libopenmpi-dev > /dev/null 2>& 1
  if [ $? -ne 0 ] ; then
    ERROR=1
    echo 'schism requires libopenmpi-dev installed to build'
  fi
  dpkg --list libnetcdff-dev > /dev/null 2>& 1
  if [ $? -ne 0 ] ; then
    ERROR=1
    echo 'schism requires libnetcdff-dev installed to build'
  fi
fi
if [ $ERROR -ne 0 ] ; then
  exit 1
fi

echo "FFLAGS=\"$FFLAGS\""
echo "LDFLAGS=\"$LDFLAGS\""
#exit


#-------------------------------------------------------------------------------

if [ ! -d schism ] ; then
  git clone https://github.com/schism-dev/schism
patch -p0 << EOF
--- schism/src/Hydro/schism_step.F90-orig	2023-02-07 13:09:28.554078199 +0800
+++ schism/src/Hydro/schism_step.F90	2023-02-07 13:09:03.177407840 +0800
@@ -618,9 +618,11 @@
 #endif
             enddo !i
 !\$OMP       end do
+!\$OMP end parallel
 
             !Turn off precip near land bnd
             if(iprecip_off_bnd/=0) then
+!\$OMP parallel default(shared) private(i,j)
 !\$OMP         do
               loop_prc: do i=1,np
                 if(isbnd(1,i)==-1) then
EOF
fi

#-------------------------------------------------------------------------------

if [ "$WITHFABM" = "ON" ] ; then
  if [ ! -d fabm-schism ] ; then
    git clone https://github.com/josephzhang8/fabm.git fabm-schism
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
if [ "$FC" = "ifort" ] ; then
  cat << EOF > cmake/SCHISM.local.aed
# what follows is a simple configuration for Ubuntu using ifort and gcc

set(CMAKE_Fortran_COMPILER ${FC} CACHE PATH "Path to serial Fortran compiler")
set(CMAKE_C_COMPILER gcc CACHE PATH "Path to serial C compiler")
set(CMAKE_Fortran_FLAGS_RELEASE "-O2 -qoverride-limits -qopenmp-link=static" CACHE STRING "Fortran flags" FORCE)

set(NetCDF_PARALLEL "FALSE")
#
#set(NetCDF_DIR "${NETCDF_HOME}" CACHE PATH "Default Path to NetCDF")

set(NetCDF_Fortran_DIR "${NETCDF_FORTRAN_HOME}" CACHE PATH "Path to NetCDF Fortran library")
set(NetCDF_Fortran_CONFIG_EXECUTABLE "${NETCDF_FORTRAN_HOME}/bin/nf-config" CACHE PATH "Path to NetCDF Fortran Executable")
# set(NetCDF_Fortran_LIBRARY "${NETCDF_FORTRAN_HOME}/lib/libnetcdff.a" CACHE PATH "Path to NetCDF Fortran library")
# set(NetCDF_Fortran_INCLUDE "${NETCDF_FORTRAN_HOME}/include/netcdf.mod" CACHE PATH "Path to NetCDF Fortran Include File")

set(NetCDF_C_DIR "/usr" CACHE PATH "Path to NetCDF C")
set(NetCDF_C_CONFIG_EXECUTABLE "/usr/bin/nc-config" CACHE PATH "Path to NetCDF C Executable")
# set(NetCDF_C_LIBRARY "/usr/lib/x86_64-linux-gnu/libnetcdf.so" CACHE PATH "Path to NetCDF C library")
# set(NetCDF_C_INCLUDE "/usr/include/netcdf.h" CACHE PATH "Path to NetCDF C include file")

# Doesn't seem to get used
#set(MPI_Fortran_LINK_FLAGS "-L/opt/intel/oneapi/mpi/latest/lib/release -static" CACHE_PATH "Path to MPI")

EOF
else
  cp cmake/SCHISM.local.ubuntu cmake/SCHISM.local.aed
fi

#-------------------------------------------------------------------------------

cat << EOF > cmake/SCHISM.local.build.aed
######################### SCHISM COMPONENTS #########################
#  This is AED test cache initialization file for choosing the SCHISM modules and algorithm settings
# It is taken from cmake/SCHISM.local.build

#   For purposes of clarity and re-usability, the configuration examples have been separated into
#   system locations and compilers (see SCHISM.local.system) and module/algorithm choices (e.g. USE_SED,TVD_LIM).
#   This file is an example of the latter.

#   In practice, you don't have to separate them. If you do,
#   cmake works fine with two init files: cmake -C<system_init> -C<build_init>
#
#   PETSc status: discussions with PETSc developers indicate older versions are not actively supported with cmake,
#   so use gnu make instead.
#####################################################################
#
#Default is NO_PARMETIS=OFF, i.e. use ParMETIS
set(NO_PARMETIS OFF CACHE BOOLEAN "Turn off ParMETIS")

#   Algorithm choices
# TVD_LIM must be one of SB, VL, MM or OS for Superbee, Van Leer, Minmod, or Osher.")
set (TVD_LIM VL CACHE STRING "Flux limiter")
#Turn OLDIO off to use the new scribe based I/O
set (OLDIO OFF CACHE BOOLEAN "Old nc output (each rank dumps its own data)")

set (PREC_EVAP OFF CACHE BOOLEAN "Include precipitation and evaporation calculation")
set (USE_BULK_FAIRALL OFF CACHE BOOLEAN "Enable Fairall bulk scheme for air-sea exchange")
set (IMPOSE_NET_FLUX  OFF CACHE BOOLEAN "Specify net heat and salt fluxes in sflux")
##Older versions of GOTM (3.*) have issues with netcdf v4, so are not maintained
set (USE_GOTM OFF CACHE BOOLEAN "Use GOTM turbulence model. This just enables the build -- GOTM must still be selected in param.nml")
set (USE_HA OFF CACHE BOOLEAN "Enable harmonic analysis output modules")
set( USE_MARSH OFF CACHE BOOLEAN "Use marsh module")
set( USE_PAHM OFF CACHE BOOLEAN "Use PaHM module")

#   Enable/Disable Modules
set( USE_SED2D OFF CACHE BOOLEAN "Use 2D sediment module")
set( USE_WWM OFF CACHE BOOLEAN "Use wind-wave module")
##Coupling to WW3, either via ESMF or hard coupling (in dev)
set( USE_WW3 OFF CACHE BOOLEAN "Use Wave Watch III")
set( USE_ICE OFF CACHE BOOLEAN "Use 1-class ICE module")
set( USE_MICE OFF CACHE BOOLEAN "Use multi-class ICE module")

#Tracer models
set( USE_GEN OFF CACHE BOOLEAN "Use generic tracer module")
set( USE_AGE OFF CACHE BOOLEAN "Use age module")
set( USE_ECO OFF   CACHE BOOLEAN "Use ECO-SIM module")
set( USE_ICM OFF  CACHE BOOLEAN "Use ICM module")
set( USE_COSINE ${COSON}   CACHE BOOLEAN "Use CoSiNE module")
set( USE_FIB OFF   CACHE BOOLEAN "Use fecal indicating bacteria module")
set( USE_SED OFF   CACHE BOOLEAN "Use sediment module")

set( USE_FABM ${WITHFABM}   CACHE BOOLEAN "FABM BGC model interface")
#If FABM is on, need to set FABM_BASE (after cloning from Joseph's fork: https://github.com/josephzhang8/fabm.git).
#Use master branch of the fork
#set( FABM_BASE /sciclone/home10/wangzg/fabm CACHE STRING "Path to FABM base")
set( FABM_BASE ${CWD}/fabm-schism/ CACHE STRING "Path to FABM base")

set( USE_DVD OFF CACHE BOOLEAN "DVD module interface")

set (DEBUG OFF CACHE BOOLEAN "Enable diagnostic output")
set (USE_ANALYSIS OFF CACHE BOOLEAN "Enable (somewhat costly) derviation of derived flow/stress quantities")

EOF

#-------------------------------------------------------------------------------
# Here's the actual building stuff

mkdir build
cd build
# cmake generates a bunch of developer warnings and says to use -Wno-dev to supress
# them, but adding it here doesn't seem to do anything
cmake -Wno-dev -C ../cmake/SCHISM.local.build.aed -C ../cmake/SCHISM.local.aed ../src/ || exit 1

${MAKE} $BFLAG pschism || exit 1


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
