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
PLUS=`grep 'url = ' .git/config | sed -e 's/url = //' | sed -e 's/AquaticEcoDynamics/\n/' | tail -1`
if [ "$PLUS" = "/AED_Tools_Private" ] ; then
  PLUS="true"
else
  PLUS=false
fi
GITHOST="$HOST/AquaticEcoDynamics/"

GET_GLM="false"
GET_AED="false"
GETAED2="false"
GETPLOT="false"
GETUTIL="false"
GETPLUS="$PLUS"
GET_ELC="false"
GETAEDFV="false"

GET_EGS="false"

GETFABM="false"
GET_TFV="false"
GETGOTM="false"
GETSWN="false"
GETPHQ="false"
GETSHZ="false"
GETMODF="false"
GETTELM="false"
GET_D3D="false"

if [ $# -eq 0 ] ; then
  # The default case is to just update
  upd_list="libaed-api libaed-water libaed-benthic libaed-riparian libaed-demo libaed-dev libaed-light libplot libutil libaed-fv libaed2 libaed2-plus GLM ELCOM"
fi

#-------------------------------------------------------------------------------

while [ $# -gt 0 ] ; do
  #echo $# : $1

  case $1 in
    all)
      GET_GLM="true"
      GET_AED="true"
      GETPLOT="true"
      GETUTIL="true"
      GETAEDFV="true"
      if [ "$PLUS" = "true" ] ; then GETPLUS="true" ; fi
      GETPHQ="true"
      ;;
    GLM|glm)
      GET_GLM="true"
      GET_AED="true"
      GETPLOT="true"
      GETUTIL="true"
      ;;
    aed-fv)
      GETAEDFV="true"
      GET_AED="true"
      ;;
    libaed)
      GET_AED="true"
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
    elcom)
      GET_ELC="true"
      ;;
    aed2)
      GETAED2="true"
      ;;
    examples)
      GET_EGS="true"
      ;;
    TUFLOWFV|tuflowfv)
      GET_TFV="true"
      GETGOTM="true"
      GETAEDFV="true"
      GET_AED="true"
      GETSWN="true"
      ;;
    gotm)
      GETGOTM="true"
      ;;
    fabm)
      GETFABM="true"
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
    phreeqcrm)
      GETPHQ="true"
      ;;
    telemac)
      GETTELM="true"
      ;;
    delft3d)
      GET_D3D="true"
      ;;
#   -g|--githost)
#     GITHOST="$2"
#     shift # skip argument
#     ;;
    *)
      ;;
  esac
  shift # next
done

if [ "$GET_GLM" = "true" ]  ; then rep_list="$rep_list GLM" ; fi
if [ "$GETAEDFV" = "true" ] ; then rep_list="$rep_list libaed-fv" ; fi
if [ "$GET_AED" = "true" ]  ; then rep_list="$rep_list libaed-api libaed-water libaed-benthic libaed-demo" ; fi
if [ "$GETPLUS" = "true" ]  ; then rep_list="$rep_list libaed-riparian libaed-dev libaed-light libplot libutil" ; fi
if [ "$GETAED2" = "true" ]  ; then
    echo "Warning: libaed2 is now deprecated"
    rep_list="$rep_list libaed2"
    if [ "$GETPLUS" = "true" ]  ; then rep_list="$rep_list libaed2-plus" ; fi
fi
if [ "$GETPLOT" = "true" ]  ; then rep_list="$rep_list libplot" ; fi
if [ "$GETUTIL" = "true" ]  ; then rep_list="$rep_list libutil" ; fi
if [ "$GET_ELC" = "true" ]  ; then rep_list="$rep_list ELCOM" ; fi
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

fetch_3rd () {
  srcdir=$1
  dstdir=$2

  if [ "${dstdir}" = "" ] ; then  dstdir=$srcdir ; fi
# glog=`cat third-party/gitlog-${dstdir}`

  if [ -f ${dstdir}-aed/gitlog-${dstdir} ] ; then
    glog=`cat ${dstdir}-aed/gitlog-${dstdir}`
  elif [ -f third-party/gitlog-${dstdir} ] ; then
    glog=`cat third-party/gitlog-${dstdir}`
  else
    glog=""
  fi

  echo "===================================================="

  if [ -d ${dstdir} ] ; then
    echo "Updating ${dstdir} from " `grep -w url ${dstdir}/.git/config`

    cd ${dstdir}

    DETACHED=`git status | grep 'HEAD detached at'`
    git checkout .
    if [ "$DETACHED" != "" ] ; then git switch - ; fi
    git pull
    cd ..
  else
    echo "fetching $srcdir from ${GITHOST}${srcdir} ${dstdir}"
    git clone --recurse-submodules ${GITHOST}${srcdir} ${dstdir}
  fi

  if [ -d ${dstdir} ] ; then
    if [ "${glog}" != "" ] ; then
      cd ${dstdir}
      git checkout $glog
      cd ..
    fi
  fi

  if [ -d ${dstdir} ] ; then
    if [ -f ${dstdir}-aed/aed-${dstdir}.xdiff ] ; then
      patchf="${dstdir}-aed/aed-${dstdir}.xdiff"
    elif [ -f third-party/aed-${dstdir}.xdiff ] ; then
      patchf="third-party/aed-${dstdir}.xdiff"
    else
      patchf=""
    fi
    if [ "$patchf" != "" ] ; then
      if [ -L a ] ; then /bin/rm a ; fi
      ln -s ${dstdir} a
      patch -p0 < ${patchf}
      /bin/rm a
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
  GITHOST=https://github.com/fabm-model/
  fetch_3rd fabm.git fabm-git
fi

if [ "$GETGOTM" = "true" ] ; then
  count=$((count+1))
  GITHOST=https://github.com/gotm-model/
  fetch_3rd code gotm-git
fi

if [ "$GETSWN" = "true" ] ; then
  count=$((count+1))
  GITHOST=https://gitlab.tudelft.nl/citg/wavemodels/
  fetch_3rd swan
fi

if [ "$GETPHQ" = "true" ] ; then
  count=$((count+1))
  GITHOST=https://github.com/usgs-coupled/
  fetch_3rd phreeqcrm
fi

if [ "$GETSHZ" = "true" ] ; then
  count=$((count+1))
  GITHOST=https://github.com/schism-dev/
  fetch_3rd schism
  if [ -d schism ] ; then
    if [ ! -e schism/src/AED ] ; then
      cd schism/src
      ln -s ../../schism-aed/src/AED .
      cd ../..
    fi
  fi
fi

if [ "$GETMODF" = "true" ] ; then
  count=$((count+1))
  GITHOST=https://github.com/MODFLOW-ORG/
  fetch_3rd modflow6
fi

if [ "$GETTELM" = "true" ] ; then
  count=$((count+1))
  GITHOST=https://gitlab.pam-retd.fr/otm/
  fetch_3rd telemac-mascaret telemac
fi

if [ "$GET_D3D" = "true" ] ; then
  count=$((count+1))
  GITHOST=https://github.com/Deltares/
  fetch_3rd Delft3D delft3d
fi

#-------------------------------------------------------------------------------

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
if [ $count -eq 0 ] ; then
  echo "There do not seem to be any repositories requested or present"
  echo "Usage : "
  echo "  fetch_sources.sh [-g <githost>] <repo>"
  echo
  echo "where <repo> can be one or more of :"
  echo "  glm       : get glm [and it's dependancies]"
  echo "  elcom     : fetch the ELCOM sources"
  echo "  libaed    : fetch the libaed-\* sources"
  echo "  libplot   : fetch the libplot sources"
  echo "  libutil   : fetch the libutil sources"
  echo "  plus      : fetch the libaed-\* plus sources (private repository)"
  echo "  aed-fv    : fetch the libaed-fv sources"
  echo
  echo "  schism    : fetch the schism source"
  echo "  swan      : fetch the swan sources from delftU"
  echo "  phreeqcrm : fetch the phreeqcrm sources from water.usgs.gov"
  echo "  modflow6  : fetch the modflow source"
  echo "  delft3d   : fetch the 'delft3d 4' and 'delft3d fm' sources"
  echo "  telemac   : fetch the telemac-mascaret source"
  echo
  echo "  all       : fetch all of glm, elcom aed-fv and their requirements"
# echo
# echo "  -g|--githost <githost> : allows you to specify a different githost"
# echo "          The default is https://github.com/AquaticEcoDynamics/"
fi

exit 0
