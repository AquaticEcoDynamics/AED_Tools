#!/bin/sh

cd GLM
. ./GLM_CONFIG
cd ..
export CWD=`pwd`

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

ARGS=""
while [ $# -gt 0 ] ; do
  ARGS="$ARGS $1"
  case $1 in
    --debug)
      export DEBUG=true
      ;;
    --checks)
      export WITH_CHECKS=true
      ;;
    --mdebug)
      export MDEBUG=true
      ;;
    --fence)
      export FENCE=true
      ;;
    --fabm)
      export FABM=true
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
    --flang-new)
      export FC=flang-new
      ;;
    --flang)
      export FC=flang
      ;;
    --no-gui)
      export WITH_PLOTS=false
      export WITH_XPLOTS=false
      ;;
    *)
      ;;
  esac
  shift
done

. ${CWD}/build_env.inc

export F77=$FC
export F90=$FC
export F95=$FC

export MPI=OPENMPI

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
    which cmake > /dev/null 2>&1
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
# export FFLAGS="$FFLAGS -fPIC"
  if [ "${USE_DL}" = "true" ] ; then
    cmake ${FABMDIR} -DBUILD_SHARED_LIBS=1 || exit 1
  else
    cmake ${FABMDIR} || exit 1
  fi
  ${MAKE} || exit 1
fi

if [ "${AED2}" = "true" ] ; then
  cd "${AED2DIR}"
  ${MAKE} || exit 1
  cd ..
  if [ "${AED2PLS}" != "" ] ; then
    if [ -d "${AED2PLS}" ] ; then
      cd "${AED2PLS}"
      ${MAKE} || exit 1
      cd ..
    fi
  fi
fi

if [ "${AED}" = "true" ] || [ "${API}" = "true" ] ; then
  export WITH_AED_PLUS='true'
  . ${CWD}/build_aedlibs.inc
fi

if [ -d "${UTILDIR}" ] ; then
  echo "making libutil"
  cd "${UTILDIR}"
  ${MAKE} || exit 1
  cd "${CURDIR}/.."
fi

if [ "$OSTYPE" = "FreeBSD" ] ; then
  echo not making flang extras
  # cd ancillary/freebsd
  # ./fetch.sh
  # ${MAKE} || exit 1
elif [ "$OSTYPE" = "Msys" ] ; then
  if [ ! -d ancillary/windows ] ; then
    echo making windows ancillary extras
    cd ancillary/windows
    ./build.sh || exit 1
  fi
fi

if [ "$WITH_PLOTS" = "true" ] ; then
  echo "making libplot"
  cd "${PLOTDIR}"
  ${MAKE} || exit 1
fi

cd "${CURDIR}"
if [ -f obj/aed_external.o ] ; then
  /bin/rm obj/aed_external.o
fi

# Update versions in resource files
if [ -f src/glm.h ] ; then
  VERSION=`grep GLM_VERSION src/glm.h | cut -f2 -d\"`
else
  VERSION=`grep GLM_VERSION include/glm.h | cut -f2 -d\"`
fi
cd "${CURDIR}/win"
${CURDIR}/vers.sh $VERSION
#cd ${CURDIR}/win-dll
#${CURDIR}/vers.sh $VERSION
cd "${CURDIR}"

${MAKE} AEDBENDIR=$DAEDBENDIR AEDDMODIR=$DAEDDMODIR || exit 1
if [ "${DAEDDEVDIR}" != "" ] ; then
  if [ -d "${DAEDDEVDIR}" ] ; then
    echo now build plus version
    /bin/rm obj/aed_external.o
    ${MAKE} glm+ AEDBENDIR=$DAEDBENDIR AEDDMODIR=$DAEDDMODIR AEDRIPDIR=$DAEDRIPDIR AEDLGTDIR=$DAEDLGTDIR AEDDEVDIR=$DAEDDEVDIR PHREEQDIR=$PHREEQDIR || exit 1
  fi
fi

cd "${CURDIR}/.."

# =====================================================================
# Package building bit

# ***************************** Linux *********************************
if [ "$OSTYPE" = "Linux" ] ; then
  if [ $(lsb_release -is) = Ubuntu ] ; then
    BINPATH=binaries/ubuntu/$(lsb_release -rs)
    if [ ! -d "${BINPATH}" ] ; then
      mkdir -p "${BINPATH}"/
    fi
    cd ${CURDIR}
    if [ -x glm+ ] ; then
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

    fakeroot ${MAKE} -f debian/rules binary || exit 1

    cd ..

    mv glm*.deb ${BINPATH}/
  else
    BINPATH="binaries/$(lsb_release -is)/$(lsb_release -rs)"
    echo "No package build for $(lsb_release -is)"
  fi
fi

# ****************************** MacOS ********************************
if [ "$OSTYPE" = "Darwin" ] ; then
  # MOSLINE=`grep 'SOFTWARE LICENSE AGREEMENT FOR ' "/System/Library/CoreServices/Setup Assistant.app/Contents/Resources/en.lproj/OSXSoftwareLicense.rtf"`
  # pre Lion :   MOSNAME=`echo ${MOSLINE} | awk -F 'Mac OS X ' '{print $NF}'  | tr -d '\\' | tr ' ' '_'`
  # pre Sierra : MOSNAME=`echo ${MOSLINE} | awk -F 'OS X ' '{print $NF}'  | tr -d '\\' | tr ' ' '_'`
  # MOSNAME=`echo ${MOSLINE} | awk -F 'macOS ' '{print $NF}'  | tr -d '\\' | tr ' ' '_'`
  MOSNAME=`cat "/System/Library/CoreServices/Setup Assistant.app/Contents/Resources/en.lproj/OSXSoftwareLicense.rtf" | awk -F 'macOS ' '/SOFTWARE LICENSE AGREEMENT FOR/ {print $NF}' | tr -d '\\' | tr ' ' '_'`

  BINPATH="binaries/macos/${MOSNAME}"
  if [ ! -d "${BINPATH}" ] ; then
     mkdir -p "${BINPATH}"
  fi
  cd ${CURDIR}/macos
  if [ "${HOMEBREW}" = "" ] ; then
    HOMEBREW=false
  fi
  /bin/bash macpkg.sh ${HOMEBREW}
  mv ${CURDIR}/macos/glm_*.zip "${CURDIR}/../${BINPATH}/"

  if [ "${DAEDDEVDIR}" != "" -a -d "${DAEDDEVDIR}" ] ; then
    /bin/bash macpkg.sh ${HOMEBREW} glm+
    mv ${CURDIR}/macos/glm+_*.zip "${CURDIR}/../${BINPATH}/"
  else
    echo No GLM+
  fi
fi

# ***************************** FreeBSD *******************************
if [ "$OSTYPE" = "FreeBSD" ] ; then
  USRENV=`uname -r`
  BINPATH="binaries/freebsd/${USRENV}"
  if [ ! -d "${BINPATH}" ] ; then
    mkdir -p "${BINPATH}"
  fi

  cd ${CURDIR}/freebsd

  VERSRUL=`grep '^version:' create_pkg.sh | cut -f2 -d\"`
  if [ "$VERSION" != "$VERSRUL" ] ; then
    echo sed -e "s/version: \"${VERSRUL}\"/version: \"${VERSION}\"/" -i.x create_pkg.sh
    sed -e "s/version: \"${VERSRUL}\"/version: \"${VERSION}\"/" -i.x create_pkg.sh
    /bin/rm create_pkg.sh.x
  fi

  /bin/sh create_pkg.sh glm
  if [ -x ../glm+ ] ; then
    /bin/sh create_pkg.sh glm+
  fi

  mv *.pkg ${CURDIR}/../${BINPATH}
fi

# ***************************** Msys *******************************
if [ "$OSTYPE" = "Msys" ] ; then
  cd ${CURDIR}/..

# VERSION=`grep GLM_VERSION GLM/src/glm.h | cut -f2 -d\"`
# the above should alread exist
  BINPATH="binaries/windows"

  if [ ! -d "${BINPATH}" ] ; then
    mkdir -p "${BINPATH}"
  fi
  mkdir glm_$VERSION

  cp ancillary/windows/bin/libnetcdf.dll glm_$VERSION
  cp ancillary/windows/bin/libgd.dll glm_$VERSION
  for dll in libgfortran libgcc_s_seh libquadmath libwinpthread ; do
    dllp=`find /c/ProgramData/ -name $dll\*.dll 2> /dev/null | head -1`
    if [ "$dllp" != "" ] ; then
      echo \"$dllp\"
      cp "$dllp" glm_$VERSION
    else
      echo "$dll not found"
    fi
  done
  /bin/cp "${CURDIR}/glm" glm_$VERSION
  # zip up the bundle
  powershell -Command "Compress-Archive -LiteralPath glm_$VERSION -DestinationPath glm_$VERSION.zip"
  mv  glm_$VERSION.zip ${BINPATH}

  if [ -x ${CURDIR}/glm+ ] ; then
    mkdir glm+_$VERSION
    cp glm_$VERSION/*.dll glm+_$VERSION
    /bin/cp "${CURDIR}/glm+" glm+_$VERSION

    # zip up the + bundle
    powershell -Command "Compress-Archive -LiteralPath glm+_$VERSION -DestinationPath glm+_$VERSION.zip"
    mv glm+_$VERSION.zip ${BINPATH}
    mv glm+_$VERSION ${BINPATH}
  fi
  mv glm_$VERSION ${BINPATH}
fi

# ***************************** All *******************************
cd ${CURDIR}/..

echo Finished build for $OSTYPE

if [ -d ${BINPATH}/glm_$VERSION ] ; then
  if [ -d ${BINPATH}/glm_latest ] ; then
    /bin/rm -rf ${BINPATH}/glm_latest
  fi
  /bin/mv ${BINPATH}/glm_$VERSION ${BINPATH}/glm_latest
else
  if [ ! -d ${BINPATH}/glm_latest ] ; then
    /bin/mkdir ${BINPATH}/glm_latest
  fi
fi
echo "glm_$VERSION" > ${BINPATH}/glm_latest/VERSION
/bin/cp ${CURDIR}/glm ${BINPATH}/glm_latest
echo Generating ReleaseInfo.txt for glm
./admin/make_release_info.sh > ${BINPATH}/glm_latest/ReleaseInfo.txt

if [ -x ${CURDIR}/glm+ ] ; then
  if [ -d ${BINPATH}/glm+_$VERSION ] ; then
    if [ -d ${BINPATH}/glm+_latest ] ; then
      /bin/rm -rf ${BINPATH}/glm+_latest
    fi
    /bin/mv ${BINPATH}/glm+_$VERSION ${BINPATH}/glm+_latest
  else
    if [ ! -d ${BINPATH}/glm+_latest ] ; then
      /bin/mkdir ${BINPATH}/glm+_latest
    fi
  fi
  echo "glm+_$VERSION" > ${BINPATH}/glm+_latest/VERSION
  /bin/cp ${CURDIR}/glm+ ${BINPATH}/glm+_latest
  echo Generating ReleaseInfo.txt for glm+
  ./admin/make_release_info.sh > ${BINPATH}/glm+_latest/ReleaseInfo.txt
fi

echo Finished packaging for $OSTYPE

exit 0
