#!/bin/sh

cd libaed-fv
cd ..
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
    --no-ben)
      export NO_BEN=true
      ;;
    --no-demo)
      export NO_DEMO=true
      ;;
    --no-rip)
      export NO_RIP=true
      ;;
    --no-dev)
      export NO_DEV=true
      ;;
    *)
      ;;
  esac
  shift
done

export OSTYPE=`uname -s`

export MAKE=make
if [ "$FC" = "" ] ; then
  export FC=ifort
  if [ "$OSTYPE" = "FreeBSD" ] ; then
    export FC=flang
    export MAKE=gmake
  else
    export FC=ifort
  fi
fi

if [ "$FC" = "ifort" ] ; then
  if [ -d /opt/intel/bin ] ; then
    . /opt/intel/bin/compilervars.sh intel64
  fi
  which ifort > /dev/null 2>&1
  if [ $? != 0 ] ; then
    echo ifort compiler requested, but not found
    exit 1
  fi
fi

export F77=$FC
export F90=$FC
export F95=$FC

export CURDIR=`pwd`
export AEDFVDIR=${CURDIR}/libaed-fv
if [ ! -d ${AEDFVDIR} ] ; then
  echo no libaed-fv directory?
  exit 1
fi

echo build libaed-water
cd  ${CURDIR}/libaed-water
${MAKE} || exit 1
PARAMS=""
if [ ! -d ${CURDIR}/libaed-benthic ] ; then NO_BEN=true ; fi
if [ "${NO_BEN}" != "true" ] ; then
  echo build libaed-benthic
  cd  ${CURDIR}/libaed-benthic
  ${MAKE} || exit 1
  export DAEDBENDIR=`pwd`
  echo BEN = $DAEDBENDIR
  PARAMS="${PARAMS} AEDBENDIR=${DAEDBENDIR}"
fi
if [ ! -d ${CURDIR}/libaed-riparian ] ; then NO_RIP=true ; fi
if [ "${NO_RIP}" != "true" ] ; then
  echo build libaed-riparian
  cd  ${CURDIR}/libaed-riparian
  ${MAKE} || exit 1
  export DAEDRIPDIR=`pwd`
  echo RIP = $DAEDRIPDIR
  PARAMS="${PARAMS} AEDRIPDIR=${DAEDRIPDIR}"
fi
if [ ! -d ${CURDIR}/libaed-demo ] ; then NO_DEMO=true ; fi
if [ "${NO_DEMO}" != "true" ] ; then
  echo build libaed-demo
  cd  ${CURDIR}/libaed-demo
  ${MAKE} || exit 1
  export DAEDDMODIR=`pwd`
  echo DMO = $DAEDDMODIR
  PARAMS="${PARAMS} AEDDMODIR=${DAEDDMODIR}"
fi
if [ ! -d ${CURDIR}/libaed-dev ] ; then NO_DEV=true ; fi
if [ "${NO_DEV}" != "true" ] ; then
  echo build libaed-dev
  cd  ${CURDIR}/libaed-dev
  ${MAKE} || exit 1
  export DAEDDEVDIR=`pwd`
  echo DEV = $DAEDDEVDIR
  PARAMS="${PARAMS} AEDDEVDIR=${DAEDDEVDIR}"
fi

echo build tfv_wq
/bin/rm ${AEDFVDIR}/obj/aed_external.o
${MAKE} -C ${AEDFVDIR} ${PARAMS} || exit 1

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
EXTN="_$ISODATE$T$S$D"
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
  fi

  if [ ! -d ${BINPATH} ] ; then
     mkdir -p ${BINPATH}
  fi

  cd ${CURDIR}/libaed-fv/lib
  tar czf ${CURDIR}/${BINPATH}/libtuflowfv_external_wq${EXTN}.tar.gz libtuflowfv_external_wq.*
fi

exit 0
