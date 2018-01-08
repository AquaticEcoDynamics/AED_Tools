#!/bin/bash

cd GLM
. GLM_CONFIG
cd ..

export OSTYPE=`uname -s`

if [ "$FORTRAN_COMPILER" = "IFORT" ] ; then
   if [ `uname -m` = "i686" ] ; then
      CPU="ia32"
   else
      CPU="intel64"
   fi

   if [ -d /opt/intel/bin ] ; then
      . /opt/intel/bin/compilervars.sh $CPU
   fi
   which ifort >& /dev/null
   if [ $? != 0 ] ; then
      echo ifort compiler requested, but not found
      exit 1
   fi
fi

if [ "$FORTRAN_COMPILER" = "IFORT" ] ; then
   export PATH="/opt/intel/bin:$PATH"
   export FC=ifort
   export NETCDFHOME=/opt/intel
else
   export FC=gfortran
   export NETCDFHOME=/usr
   if [ "$OSTYPE" == "Darwin" ] ; then
     export NETCDFHOME=/opt/local
   fi
fi

export F77=$FC
export F90=$FC
export F95=$FC

export MPI=OPENMPI

export NETCDFINC=$NETCDFHOME/include
export NETCDFINCL=${NETCDFINC}
export NETCDFLIBDIR=$NETCDFHOME/lib
export NETCDFLIB=${NETCDFLIBDIR}
export NETCDFLIBNAME="-lnetcdff -lnetcdf"

if [ "$FABM" = "true" ] ; then
  export COMPILATION_MODE=production

  if [ ! -d $FABMDIR ] ; then
    echo "FABM directory not found"
    export FABM=false
  else
    which cmake >& /dev/null
    if [ $? != 0 ] ; then
      echo "cmake not found - FABM cannot be built"
      export FABM=false
    fi
  fi
  if [ "$FABM" = "false" ] ; then
    echo build with FABM requested but FABM cannot be built
    exit 1
  fi

  export FABMHOST=glm
  cd ${FABMDIR}
  if [ ! -d build ] ; then
    mkdir build
  fi
  cd build
  export EXTRA_FFLAGS+=-fPIC
  if [ "${USE_DL}" = "true" ] ; then
    cmake ${FABMDIR}/src -DBUILD_SHARED_LIBS=1 || exit 1
  else
    cmake ${FABMDIR}/src || exit 1
  fi
  make || exit 1
fi

if [ "${AED2}" = "true" ] ; then
  cd ${AED2DIR}
  make || exit 1
  cd ..
  if [ -d ${AED2PLS} ] ; then
    cd ${AED2PLS}
    make || exit 1
    cd ..
  fi
fi

if [ "$WITH_PLOTS" = "true" ] ; then
  cd ${PLOTDIR}
  make || exit 1
fi

cd ${UTILDIR}
make || exit 1

cd ${CURDIR}
make || exit
if [ -d ${AED2PLS} ] ; then
  make glm+ || exit
fi


VERSION=`grep GLM_VERSION src/glm.h | cut -f2 -d\"`

cd ${CURDIR}/win
${CURDIR}/vers.sh $VERSION
#cd ${CURDIR}/win-dll
#${CURDIR}/vers.sh $VERSION
cd ${CURDIR}/..

if [ "$OSTYPE" = "Linux" ] ; then
  if [ $(lsb_release -is) = Ubuntu ] ; then
    if [ ! -d binaries/ubuntu/$(lsb_release -rs) ] ; then
      mkdir -p binaries/ubuntu/$(lsb_release -rs)/
    fi
    cd ${CURDIR}
    VERSDEB=`head -1 debian/changelog | cut -f2 -d\( | cut -f1 -d-`
    echo debian version $VERSDEB
    if [ "$VERSION" != "$VERSDEB" ] ; then
      echo updating debian version
      dch --newversion ${VERSION}-0 "new version ${VERSION}"
    fi
    VERSRUL=`grep 'version=' debian/rules | cut -f2 -d=`
    if [ "$VERSION" != "$VERSRUL" ] ; then
      sed -i "s/version=$VERSRUL/version=$VERSION/" debian/rules
    fi

    fakeroot make -f debian/rules binary || exit 1

    cd ..

    mv glm*.deb binaries/ubuntu/$(lsb_release -rs)/
  else
    echo "No package build for $(lsb_release -is)"
  fi
fi
if [ "$OSTYPE" = "Darwin" ] ; then
  if [ ! -d binaries/macos ] ; then
     mkdir -p binaries/macos
  fi
  cd ${CURDIR}/macos
  if [ "${HOMEBREW}" = "" ] ; then
    HOMEBREW=false
  fi
  /bin/bash macpkg.sh ${HOMEBREW}
  mv ${CURDIR}/macos/glm_*.zip ${CURDIR}/../binaries/macos/

  if [ -d ${AED2PLS} ] ; then
    /bin/bash macpkg.sh ${HOMEBREW} glm+
    mv ${CURDIR}/macos/glm+_*.zip ${CURDIR}/../binaries/macos/
  fi

  cd ${CURDIR}/..
fi

exit 0
