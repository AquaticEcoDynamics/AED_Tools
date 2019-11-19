#!/bin/bash

cd GLM
. GLM_CONFIG
cd ..

while [ $# -gt 0 ] ; do
  case $1 in
    --debug)
      export DEBUG=true
      ;;
    --fence)
      export FENCE=true
      ;;
    --fabm)
      export FABM=true
      ;;
    --ifort)
      export FC=ifort
      ;;
    *)
      ;;
  esac
  shift
done

export OSTYPE=`uname -s`
if [ "$OSTYPE" == "Darwin" ] ; then
  if [ "$HOMEBREW" = "" ] ; then
    brew -v >& /dev/null
    if [ $? != 0 ] ; then
      which port >& /dev/null
      if [ $? != 0 ] ; then
        echo no ports and no brew
      else
        export MACPORTS=true
      fi
    else
      export HOMEBREW=true
    fi
  fi
fi


# if FC is not defined we look for gfortran-8 first because some systems
# will have gfortran at version 7 but also gfortran version 8 as gfortran-8
# if we can't find gfortran default to ifort
if [ "$FC" = "" ] ; then
  gfortran-8 -v >& /dev/null
  if [ $? != 0 ] ; then
    gfortran -v >& /dev/null
    if [ $? != 0 ] ; then
      export FC=ifort
    else
      VERS=`gfortran -dumpversion | cut -d\. -f1`
      if [ $VERS -ge 8 ] ; then
        export FC=gfortran
      else
        export FC=ifort
      fi
    fi
  else
    export FC=gfortran-8
  fi
fi

if [ "$FC" = "ifort" ] ; then
   # if [ `uname -m` = "i686" ] ; then
   #    CPU="ia32"
   # else
   #    CPU="intel64"
   # fi

   if [ -d /opt/intel/bin ] ; then
      # . /opt/intel/bin/compilervars.sh $CPU
      . /opt/intel/bin/compilervars.sh intel64
   fi
   which ifort >& /dev/null
   if [ $? != 0 ] ; then
      echo ifort compiler requested, but not found
      exit 1
   fi

   export PATH="/opt/intel/bin:$PATH"
   export NETCDFHOME=/opt/intel
else
   # if FC is not ifort assume that it is a variant of gfortran
   if [ "$OSTYPE" == "Darwin" ] ; then
     if [ "${HOMEBREW}" = "true" ] ; then
       export NETCDFHOME=/usr/local
     else
       export NETCDFHOME=/opt/local
     fi
   else
     export NETCDFHOME=/usr
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

if [ "$AED2DIR" = "" ] ; then
  export AED2DIR=../libaed2
fi
if [ "$PLOTDIR" = "" ] ; then
  export PLOTDIR=../libplot
fi
if [ "$UTILDIR" = "" ] ; then
  export UTILDIR=../libutil
fi

if [ "$FABM" = "true" ] ; then
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
# export EXTRA_FFLAGS+=-fPIC
  export FFLAGS+=-fPIC
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
  if [ "${AED2PLS}" != "" ] ; then
    if [ -d ${AED2PLS} ] ; then
      cd ${AED2PLS}
      make || exit 1
      cd ..
    fi
  fi
fi

if [ "$WITH_PLOTS" = "true" ] ; then
  cd ${PLOTDIR}
  make || exit 1
fi

cd ${UTILDIR}
make || exit 1

cd ${CURDIR}
make || exit 1
if [ -d ${AED2PLS} ] ; then
  make glm+ || exit 1
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
    if [ -d ${AED2PLS} ] ; then
       /bin/cp debian/control-with+ debian/control
    else
       /bin/cp debian/control-no+ debian/control
    fi
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
  MOSLINE=`grep 'SOFTWARE LICENSE AGREEMENT FOR ' '/System/Library/CoreServices/Setup Assistant.app/Contents/Resources/en.lproj/OSXSoftwareLicense.rtf'`
  # pre Lion :   MOSNAME=`echo ${MOSLINE} | awk -F 'Mac OS X ' '{print $NF}'  | tr -d '\\' | tr ' ' '_'`
  # pre Sierra : MOSNAME=`echo ${MOSLINE} | awk -F 'OS X ' '{print $NF}'  | tr -d '\\' | tr ' ' '_'`
  MOSNAME=`echo ${MOSLINE} | awk -F 'macOS ' '{print $NF}'  | tr -d '\\' | tr ' ' '_'`

  if [ ! -d "binaries/macos/${MOSNAME}" ] ; then
     mkdir -p "binaries/macos/${MOSNAME}"
  fi
  cd ${CURDIR}/macos
  if [ "${HOMEBREW}" = "" ] ; then
    HOMEBREW=false
  fi
  /bin/bash macpkg.sh ${HOMEBREW}
  mv ${CURDIR}/macos/glm_*.zip "${CURDIR}/../binaries/macos/${MOSNAME}/"

  if [ -d ${AED2PLS} ] ; then
    /bin/bash macpkg.sh ${HOMEBREW} glm+
    mv ${CURDIR}/macos/glm+_*.zip "${CURDIR}/../binaries/macos/${MOSNAME}/"
  fi

  cd ${CURDIR}/..
fi

exit 0
