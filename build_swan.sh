#!/bin/sh

# CWD should be the tools directory in which CURDIR lives
export CWD=`pwd`
# CURDIR should be the directory of the project we are building
export CURDIR=${CWD}/swan

export EXTERNAL_LIBS=static
export MAKE=make
case `uname` in
  "Darwin"|"Linux"|"FreeBSD")
    export OSTYPE=`uname -s`
    ;;
  MINGW*)
    export OSTYPE="Msys"
    ;;
esac

if [ "$OSTYPE" = "FreeBSD" ] ; then
  export FC=flang
  export CC=clang
  export MAKE=gmake
else
  export FC=gfortran
  export CC=gcc
  export MAKE=make
fi

#-------------------------------------------------------------------------------
# Now scan the argument list
ARGS=""
while [ $# -gt 0 ] ; do
  ARGS="$ARGS $1"
  case $1 in
    --shared)
      export EXTERNAL_LIBS=shared
      ;;
    --static)
      export STATIC_BUILD=true
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
    *)
      ;;
  esac
  shift
done

if [ "$FC" = "ifort" ] || [ "$FC" = "ifx" ] ; then
  if [ "$OSTYPE" = "Linux" ] ; then
    export start_sh="$(ps -p "$$" -o  command= | awk '{print $1}')" ;
    # ifort config scripts wont work with /bin/sh
    # so we restart using bash
    if [ "$start_sh" = "/bin/sh" ] ; then
      /bin/bash $0 $ARGS
      exit $?
    fi
  elif [ "$OSTYPE" = "Msys" ] ; then
  # for nmake.exe
  # export PATH="$PATH:/c/Program Files (x86)/Microsoft Visual Studio/2019/Community/VC/Tools/MSVC/14.29.30133/bin/Hostx64/x64"
    export PATH="/c/Program Files (x86)/Intel/oneAPI/compiler/latest/windows/bin/intel64:$PATH"
    export PATH="$PATH:${CWD}/ancillary/windows/bin"
    export FINALDIR="${CWD}/ancillary/windows"
  fi

  if [ -x /opt/intel/setvars.sh ] ; then
    . /opt/intel/setvars.sh
  elif [ -d /opt/intel/oneapi ] ; then
    . /opt/intel/oneapi/setvars.sh
  else
    if [ -d /opt/intel/bin ] ; then
       . /opt/intel/bin/compilervars.sh intel64
    fi
  fi

  which ${FC} > /dev/null 2>&1
  if [ $? != 0 ] ; then
     echo ${FC} compiler requested, but not found
     exit 1
  fi

  if [ -f /opt/intel/include/netcdf.mod-x ] ; then
    export NetCDF_ROOT=/opt/intel
  else
    if [ "$OSTYPE" = "Msys" ] ; then
      export NetCDF_ROOT="${CWD}/ancillary/windows"
      export NetCDF_INCLUDE_DIRS="${NetCDF_ROOT}/include"
      export NetCDF_LIBRARIES="${NetCDF_ROOT}/lib"
    else
      if [ ! -d ${CWD}/ancillary/${FC}/include ] ; then
        cd ${CWD}/ancillary/${FC}
        ./build_netcdf_f.sh
        cd ${CWD}
      fi

      export NetCDF_ROOT=${CWD}/ancillary/${FC}
    fi
  fi
  export FCB=${FC}
elif [ "$FC" = "gfortran" ] ; then
  export NetCDF_ROOT=/usr
  export FCB=gfortran
else
  export NetCDF_ROOT=/usr
  export FCB=gfortran
fi

echo which nc = `which nc-config`
echo NetCDF_ROOT = $NetCDF_ROOT
echo which ${FC} = `which ${FC}`

export F77=$FC
export F90=$FC
export F95=$FC

export MPI=OPENMPI

#----------------------------- build ------------------------------

echo build swan new
cd ${CURDIR}
if [ -d build ] ; then
  /bin/rm -r build
fi
mkdir build
cd build
if [ "$OSTYPE" = "Msys" ] ; then
  export NetCDF_ROOT=$FINALDIR
  export NetCDF_C_ROOT=$FINALDIR
  export CFLAGS="-I$FINALDIR/include"
  export CPPFLAGS="-I$FINALDIR/include"
  export LDFLAGS="-L$FINALDIR/lib"

  cmake -Wno-dev .. -DNETCDF=ON -DMPI=OFF \
         -DNetCDF::NetCDF_Fortran="${FINALDIR}/lib/netcdff.lib" \
         -DNetCDF::NetCDF_C="${FINALDIR}/lib/netcdf.lib" \
	 -DCMAKE_INSTALL_PREFIX="${FINALDIR}"

  if [ $? -ne 0 ] ; then
    echo cmake swan failed
    exit 1
  fi

  cmake --build . --clean-first --config Release --target INSTALL
  cp lib/Release/* "${FINALDIR}"/lib
  mkdir "${FINALDIR}"/include/swan
  cp mod/Release/* "${FINALDIR}"/include/swan

else
  cmake .. -DNETCDF=ON #-DMPI=ON
  make VERBOSE=1
fi

exit 0
