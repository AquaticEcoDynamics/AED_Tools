#!/bin/bash

# It seems tuflow uses v4.4.5 (from Jan 2019)
export NETCDFFV=4.4.5
#export NETCDFFV=4.6.0

export NETCDFF=netcdf-fortran-${NETCDFFV}

export CC=gcc
export FC=ifort
case `uname` in
  "Darwin"|"Linux"|"FreeBSD")
    export OSTYPE=`uname -s`
    ;;
  MINGW*)
    export OSTYPE="Msys"
    ;;
esac

if [ "$FC" = "ifort" ] ; then
  if [ -x /opt/intel/setvars.sh ] ; then
     . /opt/intel/setvars.sh
  elif [ -d /opt/intel/oneapi ] ; then
     . /opt/intel/oneapi/setvars.sh
  else
    if [ -d /opt/intel/bin ] ; then
       . /opt/intel/bin/compilervars.sh intel64
    fi
    which ifort > /dev/null 2>&1
    if [ $? != 0 ] ; then
       echo ifort compiler requested, but not found
       exit 1
    fi
  fi
fi

export F77=$FC
export F90=$FC
export F95=$FC

if [ ! -f ${NETCDFF}.tar.gz ] ; then
   echo fetching ${NETCDFF}
   curl -LJO https://github.com/Unidata/netcdf-fortran/archive/refs/tags/v${NETCDFFV}.tar.gz
   if [ $? != 0 ] ; then
      echo failed to fetch ${NETCDFF}.tar.gz
   fi
fi

#===============================================================================

CWD=`pwd`
cd ..
export FINALDIR=`pwd`
cd "$CWD"

if [ ! -d "${FINALDIR}"/include ] ; then
  mkdir "${FINALDIR}"/include
fi
if [ ! -d "${FINALDIR}"/lib ] ; then
  mkdir "${FINALDIR}"/lib
fi
if [ ! -d "${FINALDIR}"/bin ] ; then
  mkdir "${FINALDIR}"/bin
fi

export CFLAGS="-I${FINALDIR}/include"
export CPPFLAGS="-I${FINALDIR}/include"
#export LDFLAGS="-static -L${FINALDIR}/lib"
export LDFLAGS="-L${FINALDIR}/lib"

if [ "$OSTYPE" = "Msys" ] ; then
  # The following gets around a problem that inside "make" the SHELL var is
  # "Program Files" somewhere and it cannot be redefined so I define XSHELL
  # and replace 'SHELL' with 'XSHELL' in the Makefiles 
  export XSHELL=/usr/bin/sh

  # choco install cmake.install --installargs '"ADD_CMAKE_TO_PATH=System"'
  # choco install pkgconfiglite
  export PKG_CONFIG_PATH=/c/ProgramData/chocolatey/bin/
  alias pkgconfig=pkg-config
fi
if [ "$OSTYPE" = "Darwin" ] ; then
  export CFLAGS="${CFLAGS} -I/opt/local/include"
  export LDFLAGS="${LDFLAGS} -L/opt/local/lib/lib"
fi

#----------------------------------------------------------------
unpack_src () {
   src=$1
   if [ ! -d $src ] ; then
      if [ -f $src.tar.gz ] ; then
       echo Unpacking $src.tar.gz
       tar -xzf $src.tar.gz
     else
       echo $src.tar.gz not found!
       exit 1
     fi
   fi
   if [ -d $src ] ; then
      echo '****************' building in $src
   else
     echo no directory for $src
     exit 1
   fi
}
#----------------------------------------------------------------

# netcdff depends on netcdf
   export PATH="$PATH:${FINALDIR}/bin"
   unpack_src  $NETCDFF
   cd $NETCDFF
#  cmake "." \
#       -G "Unix Makefiles" \
#       -DCMAKE_FIND_ROOT_PATH=${FINALDIR} \
#       -DCMAKE_INSTALL_PREFIX="${FINALDIR}"

#  export LDFLAGS="-static -L${FINALDIR}/lib"
#  export LIBS="-L${FINALDIR}/lib -lnetcdf -lhdf5_hl -lhdf5 -lm -lz -lsz -lxml2 -lcurl"
   export LIBS="-L/opt/local/lib -lnetcdf"

   ./configure --prefix=${FINALDIR} --enable-static --disable-shared

   if [ $? = 0 ] ; then
      make
      if [ $? = 0 ] ; then
         make install
      else
         echo '****' build failed for $NETCDFF
         exit 1
      fi
   else
      echo '****' config failed for $NETCDFF
      exit 1
   fi
   cd ..
   echo '****************' done building in $NETCDFF

exit 0

