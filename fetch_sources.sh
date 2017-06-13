#!/bin/sh

rep_list=""
if [ $# = 0 ] ; then
  # The default case is to fetch only libaed2
  GETAED2="true"
  GETPLOT="false"
  GETUTIL="false"
  GETFABM="false"
  GET_GLM="false"
  GETPLUS="false"
  GETFVAED="false"
fi

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

#echo list = $rep_list


if [ "$GITHOST" = "" -a "$rep_list" != "" ] ; then
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
#echo GITHOST is $GITHOST

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


if [ "$rep_list" != "" ] ; then
  echo "updating AED_Tools from " `grep -w url .git/config`
  git pull

  for src in $rep_list ; do
    fetch_it $src
  done
fi

if [ "$GETFABM" = "true" ] ; then
  if [ ! -d fabm-git ] ; then
    git clone git://git.code.sf.net/p/fabm/code fabm-git
  fi
fi

exit 0
