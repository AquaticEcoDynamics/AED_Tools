#!/bin/sh
#-------------------------------------------------------------------------------
#  Script to fetch sources for the tools and utilities
#-------------------------------------------------------------------------------

rep_list=""
upd_list=""
count=0

if [ $# = 0 ] ; then
  # The default case is to just update
  GETAED="false"
  GETAED2="false"
  GETPLOT="false"
  GETUTIL="false"
  GETFABM="false"
  GET_GLM="false"
  GETPLUS="false"
  GETAEDFV="false"
  GET_ALM="false"
  GET_EGS="false"
  upd_list="libaed-water libaed-benthic libaed-demo libaed-riparian libaed-dev libaed-light libplot libutil GLM libaed-fv libaed2 libaed2-plus fabm-git"
fi

#-------------------------------------------------------------------------------

while [ $# -gt 0 ] ; do
  #echo $# : $1

  case $1 in
    all)
      GETAED="true"
      GETPLOT="true"
      GETUTIL="true"
      GET_GLM="true"
      GETAEDFV="true"
      GETAED2="true"
      GETPLUS="false"
      GETFABM="false"
      ;;
    ALM|alm)
      GET_ALM="true"
      ;;
    GLM|glm)
      GETAED="true"
      GETPLOT="true"
      GETUTIL="true"
      GET_GLM="true"
      GETAED2="true"
      GETFABM="false"
      ;;
    aed-fv)
      GETAEDFV="true"
      GETAED="true"
      ;;
    libaed2)
      GETAED2="true"
      ;;
    libaed)
      GETAED="true"
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
if [ "$GETAEDFV" = "true" ] ; then rep_list="$rep_list libaed-fv" ; fi
if [ "$GETAED" = "true" ]  ; then rep_list="$rep_list libaed-water libaed-benthic libaed-demo" ; fi
if [ "$GETAED2" = "true" ]  ; then rep_list="$rep_list libaed2" ; fi
if [ "$GETPLUS" = "true" ]  ; then
    rep_list="$rep_list libaed-riparian libaed-dev libaed-light"
    if [ "$GETAED2" = "true" ]  ; then rep_list="$rep_list libaed2-plus" ; fi
fi
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
    echo "Updating $dst from " `grep -w url $dst/.git/config`

    cd $dst
    BRANCH=`git branch | grep '*' | cut -f2 -d\ `
    git pull origin $BRANCH
    cd ..
  else
    echo "fetching $src from ${GITHOST}$src $dst"

    git clone ${GITHOST}$src $dst
  fi
}

#-------------------------------------------------------------------------------

if [ "$upd_list" != "" ] ; then
  echo "updating . from " `grep -w url .git/config`
  git pull
  for src in $upd_list ; do
    if [ -d $src ] ; then
      count=$((count+1))
      echo "Updating $src from " `grep -w url $src/.git/config`

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
  count=$((count+1))
  if [ ! -d fabm-git ] ; then
    echo "===================================================="
    echo "fetching fabm from https://github.com/fabm-model/fabm.git"
    git clone https://github.com/fabm-model/fabm.git fabm-git
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
  echo "  libaed  : fetch the libaed-\* sources"
  echo "  libplot : fetch the libplot sources"
  echo "  libutil : fetch the libutil sources"
  echo "  plus    : fetch the libaed-\* plus sources (private repository)"
  echo "  aed-fv  : fetch the libaed-fv sources"
  echo "  fabm    : fetch the fabm sources (possible dependancy for glm)"
  echo
  echo "  all     : fetch them all"
  echo
  echo "  -g|--githost <githost> : allows you to specify a different githost"
  echo "          The default is https://github.com/AquaticEcoDynamics/"
fi

exit 0
