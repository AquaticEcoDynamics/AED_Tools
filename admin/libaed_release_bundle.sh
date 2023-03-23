#!/bin/sh
#
# libaed_release_bundle.sh
#
# Script to bundle up libaed-* as a libaed.tgz

CWD=`pwd`


export AED_VRS=""
export DO_TAG=""
export WITH_TAG=""
export HAVE_TAG=""

while [ $# -gt 0 ] ; do
  case $1 in
    --do-tagging)
      export DO_TAG=true
      export WITH_TAG="$1"
      if [ $# -gt 1 ] ; then
         if [ "${2#--*}" = "$2" ] ; then
           AED_VRS="$2"
           shift
         fi
      fi
      ;;
    --tag)
      if [ $# -gt 1 ] ; then
         if [ "${2#--*}" = "$2" ] ; then
           export HAVE_TAG="$2"
           shift
         fi
      fi
      ;;
    *)
      ;;
  esac
  shift
done

# start by cleaning the respositories
echo cleaning repositories ....
./clean.sh > /dev/null 2>&1
echo ... done

if [ -d tttt ] ; then
   /bin/rm -rf tttt
fi

mkdir tttt

if [ "$AED_VRS" = "" ] ; then
  AED_VRS=`grep AED_VERSION libaed-water/include/aed.h | grep -w define | cut -f2 -d\"`
  AED_PVRS=`grep AED_PLUS_VERSION libaed-water/include/aed+.h | grep -w define | cut -f2 -d\"`
fi
if [ "${DO_TAG}" = "true" ] ; then
  if [ "$HAVE_TAG" = "" ] ; then
    export PRTAG="AED_${AED_VRS}"
  else
    export PRTAG="${HAVE_TAG}"
  fi
fi

set_tag () {
  if [ -d $src ] ; then
    echo setting tag for $src
    cd $src
    echo git tag -a ${PRTAG} -m \"libaed-\* Build Version ${AED_VRS}\"
    git tag -a ${PRTAG} -m "libaed-\* Build Version ${AED_VRS}"
    echo git push origin ${PRTAG}
    git push origin ${PRTAG}
    cd ..
  fi
}

if [ "${DO_TAG}" = "true" ] ; then
  for src in libaed-water libaed-benthic libaed-demo ; do
     set_tag ${src}
  done
fi

tar cf - libaed-water | (cd tttt; tar xf -)
/bin/rm -rf tttt/libaed-water/.git*

tar cf - libaed-benthic | (cd tttt; tar xf -)
/bin/rm -rf tttt/libaed-benthic/.git*

tar cf - libaed-demo | (cd tttt; tar xf -)
/bin/rm -rf tttt/libaed-demo/.git*

if [ `find tttt/ -name .DS_Store` ] ; then
  /bin/rm `find tttt/ -name .DS_Store`
fi
if [ `find tttt/ -name ._.DS_Store` ] ; then
  /bin/rm `find tttt/ -name ._.DS_Store`
fi

mv tttt libaed-${AED_VRS}
tar czf libaed-${AED_VRS}.tar.gz libaed-${AED_VRS}
zip -rq libaed-${AED_VRS}.zip libaed-${AED_VRS}
mv libaed-${AED_VRS} tttt

if [ -d libaed-dev ] ; then
  if [ "${DO_TAG}" = "true" ] ; then
    if [ "$HAVE_TAG" = "" ] ; then
      export PRTAG="AED_${AED_PVRS}"
    fi
    for src in libaed-riparian libaed-dev ; do
       set_tag ${src}
    done
  fi

  tar cf - libaed-riparian | (cd tttt; tar xf -)
  /bin/rm -rf tttt/libaed-riparian/.git*

  tar cf - libaed-light | (cd tttt; tar xf -)
  /bin/rm -rf tttt/libaed-light/.git*

  tar cf - libaed-dev | (cd tttt; tar xf -)
  /bin/rm -rf tttt/libaed-dev/.git*

  if [ `find tttt/ -name .DS_Store` ] ; then
    /bin/rm `find tttt/ -name .DS_Store`
  fi
  if [ `find tttt/ -name ._.DS_Store` ] ; then
    /bin/rm `find tttt/ -name ._.DS_Store`
  fi

  mv tttt libaed_Plus-${AED_PVRS}
  tar czf libaed_Plus-${AED_PVRS}.tar.gz libaed_Plus-${AED_PVRS}
  zip -rq libaed_Plus-${AED_PVRS}.zip libaed_Plus-${AED_PVRS}
  mv libaed_Plus-${AED_PVRS} tttt
fi

/bin/rm -rf tttt
mkdir -p binaries/sources
mv libaed-${AED_VRS}.tar.gz libaed-${AED_VRS}.zip binaries/sources
if [ -d libaed-dev ] ; then
   mv libaed_Plus-${AED_PVRS}.tar.gz libaed_Plus-${AED_PVRS}.zip binaries/sources
fi

exit 0
