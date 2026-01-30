#!/bin/sh
#-------------------------------------------------------------------------------
#  Script to fetch sources for the tools and utilities
#-------------------------------------------------------------------------------

rep_list=""
upd_list=""
count=0

# get host out of our .git/config file
#GITHOST=git@github.com:AquaticEcoDynamics/
HOST=`grep 'url = ' .git/config | sed -e 's/url = //' | sed -e 's/AquaticEcoDynamics/\n/' | head -1`
GITHOST="$HOST/AquaticEcoDynamics/"

GET_GLM="false"
GETAED="false"
GETAED2="false"
GETPLOT="false"
GETUTIL="false"
GETFABM="false"
GETPLUS="false"
GETAEDFV="false"
GET_EGS="false"
GET_TFV="false"
GETGOTM="false"
GETELC="false"
GETSWN="false"
GETPHQ="false"
GETSHZ="false"
GETMODF="false"

if [ $# = 0 ] ; then
  # The default case is to just update
  upd_list="libaed-api libaed-water libaed-benthic libaed-riparian libaed-demo libaed-dev libaed-light libplot libutil libaed-fv libaed2 libaed2-plus GLM ELCOM"
fi

#-------------------------------------------------------------------------------

while [ $# -gt 0 ] ; do
  #echo $# : $1

  case $1 in
    all)
      GET_GLM="true"
      GETAED="true"
      GETPLOT="true"
      GETUTIL="true"
      GETAEDFV="true"
      GETPLUS="true"
      GETPHQ="true"
      ;;
    GLM|glm)
      GET_GLM="true"
      GETAED="true"
      GETPLOT="true"
      GETUTIL="true"
      ;;
    aed-fv)
      GETAEDFV="true"
      GETAED="true"
      ;;
    libaed)
      GETAED="true"
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
      GETPHQ="true"
      ;;
    fabm)
      GETFABM="true"
      ;;
    examples)
      GET_EGS="true"
      ;;
    TUFLOWFV|tuflowfv)
      GET_TFV="true"
      GETGOTM="true"
      GETAEDFV="true"
      GETAED="true"
      GETSWN="true"
      ;;
    gotm)
      GETGOTM="true"
      ;;
    elcom)
      GETELC="true"
      ;;
    swan)
      GETSWN="true"
      ;;
    schism)
      GETSHZ="true"
      ;;
    modflow)
      GETMODF="true"
      ;;
    aed2)
      GETAED2="true"
      ;;
    phreeqcrm)
      GETPHQ="true"
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
if [ "$GETAED" = "true" ]  ; then rep_list="$rep_list libaed-api libaed-water libaed-benthic libaed-demo" ; fi
if [ "$GETPLUS" = "true" ]  ; then rep_list="$rep_list libaed-riparian libaed-dev libaed-light" ; fi
if [ "$GETAED2" = "true" ]  ; then
    rep_list="$rep_list libaed2"
    if [ "$GETPLUS" = "true" ]  ; then rep_list="$rep_list libaed2-plus" ; fi
fi
if [ "$GETPLOT" = "true" ]  ; then rep_list="$rep_list libplot" ; fi
if [ "$GETUTIL" = "true" ]  ; then rep_list="$rep_list libutil" ; fi
if [ "$GET_EGS" = "true" ]  ; then rep_list="$rep_list GLM_Examples" ; fi
if [ "$GETELC" = "true" ]  ; then rep_list="$rep_list ELCOM" ; fi

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

    if [ "$src" = "schism" ] ; then
      git clone --recurse-submodules ${GITHOST}$src $dst
    else
      git clone ${GITHOST}$src $dst
    fi
  fi
}

#-------------------------------------------------------------------------------

if [ "$upd_list" != "" ] ; then
  echo "Updating . from " `grep -w url .git/config`
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

if [ "$GETGOTM" = "true" ] ; then
  count=$((count+1))
  if [ ! -d gotm-git ] ; then
# Two possible places :
#   1) GOTM git repository
#   2) AED's internal git copy of old
#
#   1)
#   git clone git://git.code.sf.net/p/gotm/code gotm-git
#   git clone https://github.com/gotm-model/code gotm-git

#   2)
    GITHOST=git@githost.aed-net.science.uwa.edu.au:
    fetch_it gotm-git
  else
    src='gotm-git'
    echo "Updating $src from " `grep -w url $src/.git/config`
    cd gotm-git
    git pull
    cd ..
  fi
fi

if [ "$GETSWN" = "true" ] ; then
  count=$((count+1))
  if [ ! -d swan ] ; then
    GITHOST=https://gitlab.tudelft.nl/citg/wavemodels/
    fetch_it swan
  else
    src='swan'
    echo "Updating $src from " `grep -w url $src/.git/config`
    cd swan
    git pull
    cd ..
  fi
fi

if [ "$GETPHQ" = "true" ] ; then
  count=$((count+1))
  if [ ! -d phreeqcrm ] ; then
    GITHOST=https://github.com/usgs-coupled/
    fetch_it phreeqcrm
  else
    src='phreeqcrm'
    echo "Updating $src from " `grep -w url $src/.git/config`
    cd phreeqcrm
    git pull
    cd ..
  fi
fi

if [ "$GETSHZ" = "true" ] ; then
  count=$((count+1))
  if [ ! -d schism ] ; then
    GITHOST=https://github.com/schism-dev/
    fetch_it schism
  else
    src='schism'
    echo "Updating $src from " `grep -w url $src/.git/config`
    cd schism
    git pull
    cd ..
  fi
fi

if [ "$GETMODF" = "true" ] ; then
  count=$((count+1))
  if [ ! -d modflow6 ] ; then
    GITHOST=https://github.com/MODFLOW-ORG/
    fetch_it modflow6
  else
    src='modflow6'
    echo "Updating $src from " `grep -w url $src/.git/config`
    cd modflow6
    git pull
    cd ..
  fi
fi

if [ "$GET_TFV" = "true" ] ; then
  count=$((count+1))
  # ME=`hostname -f`
  # WHEREAMI=`echo $ME | cut -d. -f2-`
  # if [ "$WHEREAMI" != "aed-net.science.uwa.edu.au" ] ; then
  #    echo "It looks like you are not in the aed network, you probably can't get tuflowfv sources"
  # fi
  if [ -d tuflowfv-lib ] ; then
    src='tuflowfv-lib'
    echo "Updating $src from " `grep -w url $src/.git/config`
    cd tuflowfv-lib
    git pull
    cd ..
  else
    GITHOST=git@githost.aed-net.science.uwa.edu.au:
    fetch_it tuflowfv-lib
  fi
  # This may need tweaking
  if [ "`hostname`" = "phyto" ] ; then
    if [ -d tuflowfv ] ; then
      src='tuflowfv'
      echo "Updating $src from " `grep -w url $src/.git/config`
      cd tuflowfv
      git pull
      cd ..
    else
      GITHOST=git@githost.aed-net.science.uwa.edu.au:
      fetch_it tuflowfv-aed tuflowfv
    fi
  fi
fi

#-------------------------------------------------------------------------------
if [ $count = 0 ] ; then
  echo "There do not seem to be any repositories requested or present"
  echo "Usage : "
  echo "  fetch_sources.sh [-g <githost>] <repo>"
  echo
  echo "where <repo> can be one or more of :"
  echo "  glm       : get glm [and it's dependancies]"
  echo "  libaed    : fetch the libaed-\* sources"
  echo "  libplot   : fetch the libplot sources"
  echo "  libutil   : fetch the libutil sources"
  echo "  plus      : fetch the libaed-\* plus sources (private repository)"
  echo "  aed-fv    : fetch the libaed-fv sources"
  echo
  echo "  elcom     : fetch the ELCOM sources"
  echo "  swan      : fetch the swan sources from delftU"
  echo "  phreeqcrm : fetch the phreeqcrm sources from water.usgs.gov"
  echo "  schism    : fetch the schism sources from github"
  echo
  echo "  all       : fetch them all"
  echo
  echo "  -g|--githost <githost> : allows you to specify a different githost"
  echo "          The default is https://github.com/AquaticEcoDynamics/"
fi

exit 0
