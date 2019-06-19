#!/bin/sh
#-------------------------------------------------------------------------------
#  Script to fetch sources for the tools and utilities
#-------------------------------------------------------------------------------

rep_list=""
upd_list=""
count=0

if [ $# = 0 ] ; then
  # The default case is to just update
  GETAED2="false"
  GETPLOT="false"
  GETUTIL="false"
  GETFABM="false"
  GET_GLM="false"
  GETPLUS="false"
  GETFVAED="false"
  GET_TFV="false"
  GETGOTM="false"
  GET_ALM="false"
  GET_EGS="false"
  upd_list="libaed2 libplot libutil GLM libfvaed2 libaed2-plus TUFLOWFV gotm-git"
fi

#-------------------------------------------------------------------------------

while [ $# -gt 0 ] ; do
  #echo $# : $1

  case $1 in
    all)
      GETAED2="true"
      GETPLOT="true"
      GETUTIL="true"
      GETFABM="true"
      GET_GLM="true"
      GETPLUS="true"
      GETFVAED="true"
      GET_TFV="false"
      GETGOTM="false"
      ;;
    ALM|alm)
      GET_ALM="true"
      ;;
    GLM|glm)
      GETAED2="true"
      GETPLOT="true"
      GETUTIL="true"
      GETFABM="true"
      GET_GLM="true"
      ;;
    fvaed2)
      GETFVAED="true"
      GETAED2="true"
      ;;
    libaed2)
      GETAED2="true"
      ;;
    libplot)
      GETPLOT="true"
      ;;
    libutil)
      GETUTIL="true"
      ;;
    plus)
      GETPLUS="true"
      ;;
    fabm)
      GETFABM="true"
      ;;
    TUFLOWFV|tuflowfv)
      GET_TFV="true"
      GETGOTM="true"
      GETFVAED="true"
      GETAED2="true"
      ;;
    examples)
      GET_EGS="true"
      ;;
    -g|--githost)
      GITHOST="$2"
      shift # skip argument
      ;;
    *)
      ;;
  esac
  shift # next
done

if [ "$GET_GLM" = "true" ]  ; then rep_list="$rep_list GLM" ; fi
if [ "$GETFVAED" = "true" ] ; then rep_list="$rep_list libfvaed2" ; fi
if [ "$GETAED2" = "true" ]  ; then rep_list="$rep_list libaed2" ; fi
if [ "$GETPLUS" = "true" ]  ; then rep_list="$rep_list libaed2-plus" ; fi
if [ "$GETPLOT" = "true" ]  ; then rep_list="$rep_list libplot" ; fi
if [ "$GETUTIL" = "true" ]  ; then rep_list="$rep_list libutil" ; fi
if [ "$GET_ALM" = "true" ]  ; then rep_list="$rep_list ALM" ; fi
if [ "$GET_EGS" = "true" ]  ; then rep_list="$rep_list GLM_Examples" ; fi

#-------------------------------------------------------------------------------

fetch_it () {
  src=$1
  dst=$2

  echo "===================================================="

  if [ "$dst" = "" ] ; then
    dst=$src
  fi

  if [ -d $dst ] ; then
    echo "updating $dst from " `grep -w url $dst/.git/config`

    cd $dst
    BRANCH=`git branch | grep '*' | cut -f2 -d\ `
    git pull origin $BRANCH
    cd ..
  else
    echo "fetching $src from ${GITHOST}$src $dst"

    git clone ${GITHOST}$src $dst

    if [ -d $dst ] ; then
      cd $dst
      git checkout dev
      cd ..
    fi
  fi
}

#-------------------------------------------------------------------------------

if [ "$upd_list" != "" ] ; then
  echo "updating AED_Tools from " `grep -w url .git/config`
  git pull

  count=0
  for src in $upd_list ; do
    if [ -d $src ] ; then
      count=$((count+1))
      echo "updating $src from " `grep -w url $src/.git/config`

      cd $src
      BRANCH=`git branch | grep '*' | cut -f2 -d\ `
      git pull origin $BRANCH
      cd ..
    fi
  done
elif [ "$rep_list" != "" ] ; then
  # echo list = $rep_list

  if [ "$GITHOST" = "" ] ; then
    REPOS=`grep -w url .git/config | cut -d\  -f3`
    NWORDS=`echo $REPOS | cut -d: -f2 | sed 's:/: :g' | wc -w`

    if [ "`echo $REPOS | grep '@'`" != "" ] ; then
      if [ $NWORDS = 1 ] ; then #
        GITHOST=`echo $REPOS | cut -d: -f1`:
      else
        NWORDS=`expr $NWORDS - 1`
        GITHOST=`echo $REPOS |  cut -d\/ -f-$NWORDS`/
      fi
    else
      NWORDS=`expr $NWORDS + 1`
      GITHOST=`echo $REPOS |  cut -d\/ -f-$NWORDS`/
    fi
  fi
  # echo GITHOST is $GITHOST

  for src in $rep_list ; do
    count=$((count+1))
    fetch_it $src
  done
fi

#-------------------------------------------------------------------------------

if [ "$GETFABM" = "true" ] ; then
  if [ ! -d fabm-git ] ; then
    echo "===================================================="
    echo "fetching fabm from https://github.com/fabm-model/fabm.git"
    git clone https://github.com/fabm-model/fabm.git fabm-git
  fi
fi

if [ "$GETGOTM" = "true" ] ; then
  if [ ! -d gotm-git ] ; then
# Two possible places :
#   1) GOTM git repository
#   2) AED's internal git copy of old
#
#   1)
#   git clone git://git.code.sf.net/p/gotm/code gotm-git
    git clone https://github.com/gotm-model/code gotm-git

#   2)
#   GITHOST=https://githost.aed-net.science.uwa.edu.au/private/
#   fetch_it GOTM gotm-git
  fi
fi

if [ "$GET_TFV" = "true" ] ; then
  ME=`hostname -f`
  WHEREAMI=`echo $ME | cut -d. -f2-`
  if [ "$WHEREAMI" != "aed-net.science.uwa.edu.au" ] ; then
     echo "It looks like you are not in the aed network, you probably can't get tuflowfv sources"
  fi
  if [ ! -d TUFLOWFV ] ; then
    echo "===================================================="
    GITHOST=https://githost.aed-net.science.uwa.edu.au/private/
    fetch_it TUFLOWFV
  fi
fi

#-------------------------------------------------------------------------------
if [ $count = 0 ] ; then
  echo "There do not seem to be any repositories requested or present"
  echo "Usage : "
  echo "  fetch_sources.sh [-g <githost>] <repo>"
  echo
  echo "where <repo> can be one or more of :"
  echo "  glm     : get glm [and it's dependancies]"
  echo "  libaed2 : fetch the libaed2 sources"
  echo "  libplot : fetch the libplot sources"
  echo "  libutil : fetch the libutil sources"
  echo "  plus    : fetch the libaed2-plus sources (private repository)"
  echo "  fvaed2  : fetch the libfvaed2 sources"
  echo "  fabm    : fetch the fabm sources (possible dependancy for glm)"
  echo
  echo "  all     : fetch them all"
  echo
  echo "  -g|--githost <githost> : allows you to specify a different githost"
  echo "          The default is https://github.com/AquaticEcoDynamics/"
fi

exit 0
