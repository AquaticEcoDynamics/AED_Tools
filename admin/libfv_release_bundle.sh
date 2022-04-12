#!/bin/sh
#
# libfv_release_bundle.sh
#
# Script to bundle up libaed-fv and libaed-* as a libfv.tgz

CWD=`pwd`

export FC=ifort

export LFV_VRS=""
export DO_TAG=""
export WITH_TAG=""
export HAVE_TAG=""
AED_VRS=`grep AED_VERSION libaed-water/include/aed.h | grep -w define | cut -f2 -d\"`
AED_PVRS=`grep AED_PLUS_VERSION libaed-water/include/aed+.h | grep -w define | cut -f2 -d\"`

while [ $# -gt 0 ] ; do
  case $1 in
    --do-tagging)
      export DO_TAG=true
      export WITH_TAG="$1"
      if [ $# -gt 1 ] ; then
#        if [[ "$2" != "--"* ]] ; then
         if [ "${2#--*}" = "$2" ] ; then
           LFV_VRS="$2"
           shift
         fi
      fi
      ;;
    --tag)
      if [ $# -gt 1 ] ; then
#        if [[ "$2" != "--"* ]] ; then
         if [ "${2#--*}" = "$2" ] ; then
            HAVE_TAG="$2"
         fi
      fi
      ;;
    *)
      ;;
  esac
  shift
done

# start by cleaning the respositories
# this would be done by "admin/libaed_release_bundle.sh"
# echo cleaning repositories ....
# ./clean.sh > /dev/null 2>&1
# echo ... done

# this also should be done by "admin/libaed_release_bundle.sh"
#if [ -d tttt ] ; then
#   /bin/rm -rf tttt
#fi

if [ "$LFV_VRS" = "" ] ; then
  LFV_VRS=`grep FV_AED_VERS libaed-fv/src/fv_aed.F90 | grep -w define | cut -f2 -d\"`
fi
if [ "${DO_TAG}" = "true" ] ; then
  if [ "$HAVE_TAG" = "" ] ; then
    export PRTAG="LFV_${LFV_VRS}"
  else
    export PRTAG="${HAVE_TAG}"
  fi
fi

./admin/libaed_release_bundle.sh ${WITH_TAG} --tag "${PRTAG}"
mkdir tttt

set_tag () {
  if [ -d $src ] ; then
    echo setting tag for $src
    cd $src
    echo git tag -a ${PRTAG} -m \"libaed-fv Build Version ${LFV_VRS}\"
    git tag -a ${PRTAG} -m "libaed-fv Build Version ${LFV_VRS}"
    echo git push origin ${PRTAG}
    git push origin ${PRTAG}
    cd ..
  fi
}

if [ "${DO_TAG}" = "true" ] ; then
  export src="libaed-fv"
  set_tag libaed-fv
fi

zcat binaries/sources/libaed-${AED_VRS}.tar.gz | (cd tttt; tar xf -)

tar cf - libaed-fv | (cd tttt; tar xf -)
/bin/rm -rf tttt/libaed-fv/.git*

tar cf - admin build_aed-fv.sh READ* fetch* | (cd tttt; tar xf -)

if [ `find tttt/ -name .DS_Store` ] ; then
  /bin/rm `find tttt/ -name .DS_Store`
fi
if [ `find tttt/ -name ._.DS_Store` ] ; then
  /bin/rm `find tttt/ -name ._.DS_Store`
fi

mv tttt libaed_fv-${LFV_VRS}
tar czf libaed_fv-${LFV_VRS}.tar.gz libaed_fv-${LFV_VRS}
zip -rq libaed_fv-${LFV_VRS}.zip libaed_fv-${LFV_VRS}
mv libaed_fv-${LFV_VRS} tttt

if [ -d libaed-dev ] ; then
  zcat binaries/sources/libaed_Plus-${AED_PVRS}.tar.gz | (cd tttt; tar xf -)

  if [ `find tttt/ -name .DS_Store` ] ; then
    /bin/rm `find tttt/ -name .DS_Store`
  fi
  if [ `find tttt/ -name ._.DS_Store` ] ; then
    /bin/rm `find tttt/ -name ._.DS_Store`
  fi

  mv tttt libaed_fv_Plus-${LFV_VRS}
  tar czf libaed_fv_Plus-${LFV_VRS}.tar.gz libaed_fv_Plus-${LFV_VRS}
  zip -rq libaed_fv_Plus-${LFV_VRS}.zip libaed_fv_Plus-${LFV_VRS}
  mv libaed_fv_Plus-${LFV_VRS} tttt
fi

/bin/rm -rf tttt
mkdir -p binaries/sources
mv libaed_fv-${LFV_VRS}.tar.gz libaed_fv-${LFV_VRS}.zip binaries/sources
if [ -d libaed-dev ] ; then
  mv libaed_fv_Plus-${LFV_VRS}.tar.gz libaed_fv_Plus-${LFV_VRS}.zip binaries/sources
fi

exit 0
