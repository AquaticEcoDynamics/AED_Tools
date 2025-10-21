#!/bin/sh

# CWD should be the tools directory in which CURDIR lives
export CWD=`pwd`
# CURDIR should be the directory of the project we are building
export CURDIR=`pwd`/libaed-fv

export SINGLE=false
export PRECISION=1
export PLOTS=false
export EXTERNAL_LIBS=shared
export DEBUG=false

export LICENSE=0

while [ $# -gt 0 ] ; do
  case $1 in
    --debug)
      export DEBUG=true
      ;;
    --fence)
      export FENCE=true
      ;;
    --static)
      export EXTERNAL_LIBS=static
      ;;
    --single)
      export SINGLE=true
      ;;
    --with-aed-plus)
      export WITH_AED_PLUS=true
      ;;
    --ifx)
      export FC=ifx
      ;;
    *)
      ;;
  esac
  shift
done

export OSTYPE=`uname -s`
case `uname` in
  "Darwin"|"Linux"|"FreeBSD")
    export OSTYPE=`uname -s`
    ;;
  MINGW*)
    export OSTYPE="Msys"
    ;;
esac

if [ "$OSTYPE" = "Msys" ] ; then
  #=============================== Windows build ===============================
  export VERSION=`grep FV_AED_VERS libaed-fv/src/fv_aed.F90 | grep define | cut -f2 -d\"`
  cd libaed-fv/win
  ../vers.sh $VERSION

  if [ -d x64-Release/tuflowfv_external_wq ] ; then
    rm -rf x64-Release/tuflowfv_external_wq
  fi
  if [ -d x64-Release/tuflowfv_external_wq_$VERSION ] ; then
    rm -rf x64-Release/tuflowfv_external_wq_$VERSION
  fi
  if [ -f x64-Release/tuflowfv_external_wq_$VERSION.zip ] ; then
    rm -f x64-Release/tuflowfv_external_wq_$VERSION.zip
  fi

  cmd.exe '/c build_fv.bat'
  if [ $? -ne 0 ] ; then
    echo errors in build
    exit 1
  fi

  cd x64-Release
  mkdir -p tuflowfv_external_wq_$VERSION
  mv tuflowfv_external_wq.??? tuflowfv_external_wq_$VERSION
  powershell -Command "Compress-Archive -LiteralPath tuflowfv_external_wq_$VERSION -DestinationPath tuflowfv_external_wq_$VERSION.zip"
  if [ $? -ne 0 ] ; then
    echo error building zipfile
    exit 1
  fi

  if [ ! -d ${CWD}/binaries/windows ] ; then
    mkdir -p ${CWD}/binaries/windows
  fi
  cp tuflowfv_external_wq_$VERSION.zip ${CWD}/binaries/windows
  exit 0
  #============================= End Windows build =============================
fi

if [ "$OSTYPE" = "FreeBSD" ] ; then
  if [ "$FC" = "" ] ; then
    export FC=flang
  fi
  export CC=clang
  export MAKE=gmake
else
  if [ "$FC" = "" ] ; then
    export FC=ifort
  fi
  export CC=gcc
  export MAKE=make
fi

export F77=$FC
export F90=$FC
export F95=$FC

. ${CWD}/build_env.inc
. ${CWD}/build_aedlibs.inc

export AEDFVDIR=${CURDIR}
if [ ! -d ${AEDFVDIR} ] ; then
  echo no libaed-fv directory?
  exit 1
fi
echo build tfv_wq
if [ -f ${AEDFVDIR}/obj/aed_external.o ] ;  then
  /bin/rm ${AEDFVDIR}/obj/aed_external.o
fi

${MAKE} -C ${AEDFVDIR} AEDWATDIR=${DAEDWATDIR} \
                       AEDBENDIR=${DAEDBENDIR} \
                       AEDDMODIR=${DAEDDMODIR} \
                       AEDRIPDIR=${DAEDRIPDIR} \
                       AEDLGTDIR=${DAEDLGTDIR} \
                       AEDDEVDIR=${DAEDDEVDIR} \
                       AEDAPIDIR=${DAEDAPIDIR} \
                       PLOTDIR=../libplot \
                       UTILDIR=../libutil || exit 1

cd ${AEDFVDIR}
get_commit_id >> ${CWD}/cur_state.log

ISODATE=`date +%Y%m%d`
cd ${CWD}

# Update versions in resource files
VERSION=`grep FV_AED_VERS ${AEDFVDIR}/src/fv_aed.F90 | head -1 | cut -f2 -d\"`
cd ${AEDFVDIR}/win
${AEDFVDIR}/vers.sh $VERSION
cd ${CWD}

if [ "$EXTERNAL_LIBS" = "shared" ] ; then
  if [ "$OSTYPE" = "Darwin" ] ; then
    MOSLINE=`grep 'SOFTWARE LICENSE AGREEMENT FOR ' '/System/Library/CoreServices/Setup Assistant.app/Contents/Resources/en.lproj/OSXSoftwareLicense.rtf'`
    MOSNAME=`echo ${MOSLINE} | awk -F 'macOS ' '{print $NF}'  | tr -d '\\' | tr ' ' '_'`

    BINPATH="binaries/macos/${MOSNAME}"
  fi
  if [ "$OSTYPE" = "Linux" ] ; then
    if [ $(lsb_release -is) = Ubuntu ] ; then
      BINPATH="binaries/ubuntu/$(lsb_release -rs)"
    fi
    cd ${AEDFVDIR}
    if [ -d debian/libaed-tfv ] ; then
      rm -r debian/libaed-tfv
    fi
    fakeroot make -f debian/rules binary || exit 1
    cd ${CWD}
  fi

  if [ ! -d ${CWD}/${BINPATH} ] ; then
    mkdir -p ${CWD}/${BINPATH}
  fi

  if [ -d ${CURDIR}/lib ] ; then
    cd ${CURDIR}/lib
    tar czf ${CWD}/${BINPATH}/libtuflowfv_external_wq_${VERSION}.tar.gz libtuflowfv_external_wq.*
    if [ "$OSTYPE" = "Linux" ] ; then
      mv ${CWD}/libaed-tfv_*_amd64.deb ${CWD}/${BINPATH}
      if [ -d ${CWD}/${BINPATH}/libaed_fv_latest ] ; then
        rm -r ${CWD}/${BINPATH}/libaed_fv_latest
      fi
      mkdir ${CWD}/${BINPATH}/libaed_fv_latest
      cd ${AEDFVDIR}/debian/libaed-tfv/usr/local/lib/
      tar cf - libaed-tfv | (cd ${CWD}/${BINPATH}/libaed_fv_latest; tar xf -)
      export MYPATH=${CWD}/${BINPATH}/libaed_fv_latest/libaed-tfv
      cd ${AEDFVDIR}
      bin/mk_tuflowfv_libaed > ${CWD}/${BINPATH}/libaed_fv_latest/tuflowfv_libaed
      chmod +x ${CWD}/${BINPATH}/libaed_fv_latest/tuflowfv_libaed
      cd ${CWD}
    fi
  else
    echo \*\*\* packaging failed no directory ${AEDFVDIR}/lib
  fi
fi

exit 0
