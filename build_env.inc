#
# Source this file in build scripts after setting FC
#

# Work out what system type we are operating on
case `uname` in
  "Darwin"|"Linux"|"FreeBSD")
    export OSTYPE=`uname -s`
    ;;
  MINGW*)
    export OSTYPE="Msys"
    ;;
esac

if [ "$OSTYPE" = "FreeBSD" ] ; then
  export MAKE=gmake
fi


#---------------
get_commit_id () {
  cid=`git log -1 | head -1 | cut -f2 -d\ `
  me=`grep -w url .git/config | head -1 | cut -f3 -d\ `
  stat=`git status -s --untracked-files=no | wc -l`
  echo "$cid from $me with $stat changes"
}
#---------------


# Are we using intel fortran (no longer supported on mac)
if [ "$FC" = "ifort"  ] || [ "$FC" = "ifx" ] ; then
  if [ "$OSTYPE" = "Linux" ] ; then
    export start_sh="$(ps -p $$ -o command= | awk '{print $1}')" ;
    # ifort config scripts wont work with /bin/sh
    # so we restart using bash
    if [ "$start_sh" = "/bin/sh" ] ; then
      /bin/bash $0 $ARGS
      exit $?
    fi

    # different releases put setup script in different places
    if [ -x /opt/intel/setvars.sh ] ; then
      . /opt/intel/setvars.sh
    elif [ -d /opt/intel/oneapi ] ; then
      . /opt/intel/oneapi/setvars.sh
    elif [ -d /opt/intel/bin ] ; then
      . /opt/intel/bin/compilervars.sh intel64
    fi
  fi
  if [ "$OSTYPE" = "Msys" ] ; then
    if [ "$MY_PS" = "" ] ; then
      export MY_PS=$$
    fi
    if [ "$MY_PS" = "$$" ] ; then
      which ${FC} > /dev/null 2>&1
      if [ $? != 0 ] ; then

        cat << EOF | cmd
@echo off

@"C:\Program Files (x86)\Intel\oneAPI\setvars.bat"
@"C:\Program Files\Git\bin\bash.exe" -c "$0 $ARGS"

EOF
        echo
        exit $?
      fi
    fi
  fi

  which ${FC} > /dev/null 2>&1
  if [ $? != 0 ] ; then
    echo ${FC} compiler requested, but not found
    exit 1
  fi
fi

# see if we have open mpi, netcdf-c and netcdf-fortran in our default path, set the
# default "home" for each

if [ "$OSTYPE" = "Msys" ] ; then
  export PATH="$PATH:`pwd`/ancillary/windows/bin"
fi

BINDIR=`which ompi_info`
if [ "$BINDIR" != "" ] ; then
  BINDIR=`dirname $BINDIR`
  OMPIBASE=`dirname $BINDIR`
fi
BINDIR=`which nc-config`
if [ "$BINDIR" != "" ] ; then
  BINDIR=`dirname $BINDIR`
  NCDFCBASE=`dirname $BINDIR`
fi
unset BINDIR
if [ "$FC" = "ifort"  ] ; then
  if [ -d /opt/intel/bin ] ; then
    BINDIR="/opt/intel/bin"
  fi
elif [ "$FC" = "ifx" ] ; then
  if [ -d ancillary/ifx/bin ] ; then
    BINDIR="ancillary/ifx/bin"
  fi
fi
if [ "$BINDIR" = "" ] ; then
  BINDIR=`which nf-config`
  BINDIR=`dirname $BINDIR`
fi
if [ "$BINDIR" != "" ] ; then
  NF_FC=`$BINDIR/nf-config --fc`
  if [ `basename $NF_FC` = ${FC} ] ; then
    BINDIR=`dirname $BINDIR`
    NCDFFBASE=`dirname $BINDIR`
  else
    echo fortran compiler mismatch on nf-config
  fi
fi
unset BINDIR

# if we haven't found netcdf-fortran ...
if [ "${NCDFFBASE}" = "" ]; then
  TCWD=`pwd`
  if [ -d ancillary ] ; then
    BASEDIR=`pwd`
  else
    if [ -d ../ancillary ] ; then
      cd ..
      BASEDIR=`pwd`
    fi
  fi
  if [ "$OSTYPE" = "Msys" ] ; then
    if [ ! -f ${BASEDIR}/ancillary/windows/include/netcdf.h ] ; then
      echo making windows ancillary extras
      cd ${BASEDIR}/ancillary/windows
      ./build.sh || exit 1
    fi
    export NCDFFBASE=${BASEDIR}/ancillary/windows/
  else
    if [ ! -f ${BASEDIR}/ancillary/${FC}/include/netcdf.h ] ; then
      cd ${BASEDIR}/ancillary/${FC}
      ./build.sh
    fi
    export NCDFFBASE=${BASEDIR}/ancillary/${FC}
  fi
  if [ "${NCDFFBASE}" != "" ]; then
    export PATH="${NCDFFBASE}/bin:${PATH}"
  fi
  cd ${TCWD}
  unset TCWD
# echo PATH=\"$PATH\"
  if [ "${NCFCBASE}" = "" ] ; then
    NCFCBASE=${NCDFFBASE}
  fi
fi

export NETCDFHOME=${NCDFFBASE}

# If we're on MacOS, work out if we have MacPorts or HomeBrew
if [ "$OSTYPE" = "Darwin" ] ; then
# export LIBRARY_PATH=/Library/Developer/CommandLineTools/SDKs/MacOSX.sdk/usr/lib
  brew -v >& /dev/null
  if [ $? != 0 ] ; then
    which port >& /dev/null
    if [ ! $? ] ; then
      export MACPORTS=true
      DEFAULTPATH=/opt/local
    fi
  else
    export HOMEBREW=true
    DEFAULTPATH=/opt/homebrew
  fi
fi

echo basic info OMPIBASE=$OMPIBASE  NCDFCBASE=$NCDFCBASE NCDFFBASE=$NCDFFBASE

