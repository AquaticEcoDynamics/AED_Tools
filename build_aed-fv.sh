#!/bin/sh

export SINGLE=false
export PRECISION=1
export PLOTS=false
export EXTERNAL_LIBS=shared
export DEBUG=false

export CWD=`pwd`
export LICENSE=0

export OSTYPE=`uname -s`
case `uname` in
  "Darwin"|"Linux"|"FreeBSD")
    export OSTYPE=`uname -s`
    ;;
  MINGW*)
    export OSTYPE="Msys"
    ;;
esac

export CURDIR=`pwd`

if [ "$OSTYPE" = "Msys" ] ; then
  cd libaed-fv/win

  cmd.exe '/c build_fv.bat'

  cd x64-Release
  mkdir -p tuflowfv_external_wq
  export VERSION=`grep FV_AED_VERS ../../src/fv_aed.F90 | grep define | cut -f2 -d\"`
  mv tuflowfv_external_wq.??? tuflowfv_external_wq
  powershell -Command "Compress-Archive -LiteralPath tuflowfv_external_wq -DestinationPath tuflowfv_external_wq_$VERSION.zip"

  if [ ! -d ${CURDIR}/binaries/windows ] ; then
    mkdir -p ${CURDIR}/binaries/windows
  fi
  cp tuflowfv_external_wq_$VERSION.zip ${CURDIR}/binaries/windows
  exit 0
fi

export MAKE=make
export CC=gcc
if [ "$OSTYPE" = "FreeBSD" ] ; then
  export FC=flang
  export CC=clang
fi

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
    --no-ben)
      export NO_BEN=true
      ;;
    --no-demo)
      export NO_DEMO=true
      ;;
    --no-rip)
      export NO_RIP=true
      ;;
    --no-light)
      export NO_LGT=true
      ;;
    --no-dev)
      export NO_DEV=true
      ;;
    --ifx)
      export FC=ifx
      ;;
    *)
      ;;
  esac
  shift
done


if [ "$OSTYPE" = "FreeBSD" ] ; then
  if [ "$FC" = "" ] ; then
    export FC=flang
    export CC=clang
  fi
  export MAKE=gmake
fi

if [ "$FC" = "" ] ; then
  export FC=ifort
fi


export F77=$FC
export F90=$FC
export F95=$FC

. ${CWD}/build_env.inc

export WITH_AED_PLUS=true
. ${CWD}/build_aedlibs.inc

export AEDFVDIR=${CURDIR}/libaed-fv
if [ ! -d ${AEDFVDIR} ] ; then
  echo no libaed-fv directory?
  exit 1
fi
echo build tfv_wq
if [ -f ${AEDFVDIR}/obj/aed_external.o ] ;  then
  /bin/rm ${AEDFVDIR}/obj/aed_external.o
fi
#${MAKE} -C ${AEDFVDIR} ${PARAMS} || exit 1
${MAKE} -C ${AEDFVDIR} AEDWATDIR=${DAEDWATDIR} \
                       AEDBENDIR=${DAEDBENDIR} \
                       AEDDMODIR=${DAEDDMODIR} \
                       AEDRIPDIR=${DAEDRIPDIR} \
                       AEDLGTDIR=${DAEDLGTDIR} \
                       AEDDEVDIR=${DAEDDEVDIR} \
                       PLOTDIR=../libplot \
                       UTILDIR=../libutil || exit 1

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

if [ "$OSTYPE" = "Linux" ] ; then
  if [ $(lsb_release -is) = Ubuntu ] ; then
    T=_u
  else
    T=_r
  fi
fi
cd ${CURDIR}

# Update versions in resource files
VERSION=`grep FV_AED_VERS ${AEDFVDIR}/src/fv_aed.F90 | head -1 | cut -f2 -d\"`
EXTN="_$VERSION$T$S$D"
cd ${AEDFVDIR}/win
${AEDFVDIR}/vers.sh $VERSION
cd ${CURDIR}

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
    cd ${CURDIR}
  fi

  if [ ! -d ${CURDIR}/${BINPATH} ] ; then
    mkdir -p ${CURDIR}/${BINPATH}
  fi

  if [ -d ${AEDFVDIR}/lib ] ; then
    cd ${AEDFVDIR}/lib
    tar czf ${CURDIR}/${BINPATH}/libtuflowfv_external_wq${EXTN}.tar.gz libtuflowfv_external_wq.*
    if [ "$OSTYPE" = "Linux" ] ; then
      mv ${CURDIR}/libaed-tfv_*_amd64.deb ${CURDIR}/${BINPATH}
      if [ -d ${CURDIR}/${BINPATH}/libaed_fv_latest ] ; then
        rm -r ${CURDIR}/${BINPATH}/libaed_fv_latest
      fi
      mkdir ${CURDIR}/${BINPATH}/libaed_fv_latest
      cd ${AEDFVDIR}/debian/libaed-tfv/usr/local/lib/
      tar cf - libaed-tfv | (cd ${CURDIR}/${BINPATH}/libaed_fv_latest; tar xf -)
      export MYPATH=${CURDIR}/${BINPATH}/libaed_fv_latest/libaed-tfv
      cd ${AEDFVDIR}
      bin/mk_tuflowfv_libaed > ${CURDIR}/${BINPATH}/libaed_fv_latest/tuflowfv_libaed
      chmod +x ${CURDIR}/${BINPATH}/libaed_fv_latest/tuflowfv_libaed
      cd ${CURDIR}
    fi
  else
    echo \*\*\* packaging failed no directory ${AEDFVDIR}/lib
  fi
fi

exit 0
