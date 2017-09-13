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
  upd_list="libaed2 libplot libutil GLM libfvaed2 libaed2-plus"
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

#-------------------------------------------------------------------------------

fetch_it () {
  src=$1

  echo "===================================================="

  if [ -d $src ] ; then
    echo "updating $src from " `grep -w url $src/.git/config`

    cd $src
    git pull # origin master
    cd ..
  else
    echo "fetching $src from ${GITHOST}$src"

    git  clone ${GITHOST}$src
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
      git pull # origin master
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
    fetch_it $src
  done
fi

#-------------------------------------------------------------------------------

if [ "$GETFABM" = "true" ] ; then
  if [ ! -d fabm-git ] ; then
    echo "===================================================="
    echo "fetching fabm from git://git.code.sf.net/p/fabm/code"
    git clone git://git.code.sf.net/p/fabm/code fabm-git
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
