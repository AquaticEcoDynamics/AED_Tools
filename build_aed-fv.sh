#!/bin/sh

export SINGLE=false
export PRECISION=1
export PLOTS=false
export EXTERNAL_LIBS=shared
export DEBUG=false

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

export CC=gcc
if [ "$OSTYPE" = "FreeBSD" ] ; then
  export FC=flang
  export CC=clang
else
  export FC=ifort
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
    *)
      ;;
  esac
  shift
done


export MAKE=make
if [ "$OSTYPE" = "FreeBSD" ] ; then
  if [ "$FC" = "" ] ; then
    export FC=flang
  fi
  export MAKE=gmake
fi

if [ "$FC" = "" ] ; then
  export FC=ifort
fi

if [ "$FC" = "ifort" ] ; then
  if [ "$OSTYPE" = "Msys" ] ; then
    start_sh="bash"
  else
    export start_sh="$(ps -p "$$" -o  command= | awk '{print $1}')" ;
  fi
  # ifort config scripts wont work with /bin/sh
  # so we restart using bash
  if [ "$start_sh" = "/bin/sh" ] ; then
    /bin/bash $0
    exit $?
  fi
  if [ -d /opt/intel/oneapi ] ; then
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
if [ ! -d ${CURDIR}/libaed-light ] ; then NO_LGT=true ; fi
if [ "${NO_LGT}" != "true" ] ; then
  echo build libaed-light
  cd  ${CURDIR}/libaed-light
  ${MAKE} || exit 1
  export DAEDLGTDIR=`pwd`
  echo LGT = $DAEDLGTDIR
  PARAMS="${PARAMS} AEDLGTDIR=${DAEDLGTDIR}"
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
if [ -f ${AEDFVDIR}/obj/aed_external.o ] ;  then
  /bin/rm ${AEDFVDIR}/obj/aed_external.o
fi
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
