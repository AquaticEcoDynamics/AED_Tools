#!/bin/sh

rep_list=""
while [ $# -gt 0 ] ; do
  #echo $# : $1

  case $1 in
    GLM|glm)
      GETAED2="true"
      GETPLOT="true"
      GETUTIL="true"
      GETFABM="true"
      GET_GLM="true"
      ;;
    TFV_WQ|tfv_wq)
      GET_TFV_WQ="true"
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
    fabm)
      GETFABM="true"
      ;;
    -g|--githost)
      GITHOST="$2"
      shift # argument
      ;;
    *)
      ;;
  esac
  shift
done


if [ "$GITHOST" = "" ] ; then
  REPOS=`grep -w url .git/config | cut -d\  -f3`
  NWORDS=`echo $REPOS | cut -d: -f2 | sed 's:/: :g' | wc -w`

  if [ "`echo $REPOS | grep '@'`" != "" ] ; then
    if [ $NWORDS == 1 ] ; then #
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

  echo "fetching $src"

  if [ -d $src ] ; then
    cd $src
    git pull # origin master
    cd ..
  else
    git  clone ${GITHOST}$src
  fi
}

if [ "$GET_GLM" = "true" ] ; then rep_list="$rep_list GLM" ; fi
if [ "$GET_TFV_WQ" = "true" ] ; then rep_list="$rep_list TFV_WQ" ; fi
if [ "$GETAED2" = "true" ] ; then rep_list="$rep_list libaed2" ; fi
if [ "$GETPLOT" = "true" ] ; then rep_list="$rep_list libplot" ; fi
if [ "$GETUTIL" = "true" ] ; then rep_list="$rep_list libutil" ; fi

echo list = $rep_list

git pull

for src in $rep_list ; do
   fetch_it $src
done

if [ "$GETFABM" = "true" ] ; then
  if [ ! -d fabm-git ] ; then
    fetch_it fabm-src
    cd fabm-src
    ./unpack.sh
    cd ..
  fi
fi

exit 0
