#!/bin/bash
#
# glm_release_bundle.sh
#
# Script to bundle up GLM with libaed-* as a GLM.tgz

CWD=`pwd`

export GLM_VRS=""
AED_VRS=`grep AED_VERSION libaed-water/include/aed.h | grep -w define | cut -f2 -d\"`
AED_PVRS=`grep AED_PLUS_VERSION libaed-water/include/aed+.h | grep -w define | cut -f2 -d\"`

while [ $# -gt 0 ] ; do
  case $1 in
    --do-tagging)
      export DO_TAG=true
      export WITH_TAG="$1"
      if [ $# -gt 1 ] ; then
         if [[ "$2" != "--"* ]] ; then
           GLM_VRS="$2"
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
# now done in "admin/libaed_release_bundle.sh"
#echo cleaning repositories ....
#./clean.sh > /dev/null 2>&1
#echo ... done

# also now done in "admin/libaed_release_bundle.sh"
if [ -d tttt ] ; then
   /bin/rm -rf tttt
fi

if [ "$GLM_VRS" = "" ] ; then
  GLM_VRS=`grep GLM_VERSION GLM/src/glm.h | cut -f2 -d\"`
fi
if [ "${DO_TAG}" = "true" ] ; then
  export PRTAG="GLM_${GLM_VRS}"
fi
echo PRTAG=${PRTAG}

./admin/libaed_release_bundle.sh ${WITH_TAG} --tag "${PRTAG}"
mkdir tttt

set_tag () {
  if [ -d $src ] ; then
    echo setting tag for $src
    cd $src
    echo git tag -a ${PRTAG} -m \"GLM Build Version ${GLM_VRS}\"
    git tag -a ${PRTAG} -m "GLM Build Version ${GLM_VRS}"
    echo git push origin ${PRTAG}
    git push origin ${PRTAG}
    cd ..
  fi
}

if [ "${DO_TAG}" = "true" ] ; then
  for src in libplot libutil libaed2 GLM ; do
     set_tag ${src}
  done
fi

zcat binaries/sources/libaed-${AED_VRS}.tar.gz | (cd tttt; tar xf -)

tar cf - libaed2 | (cd tttt; tar xf -)
/bin/rm -rf tttt/libaed2/.git*

tar cf - libplot | (cd tttt; tar xf -)
/bin/rm -rf tttt/libplot/.git*

tar cf - libutil | (cd tttt; tar xf -)
/bin/rm -rf tttt/libutil/.git*

tar cf - GLM | (cd tttt; tar xf -)
/bin/rm -rf tttt/GLM/.git*

if [ `find tttt/ -name .DS_Store` ] ; then
  /bin/rm `find tttt/ -name .DS_Store`
fi
if [ `find tttt/ -name ._.DS_Store` ] ; then
  /bin/rm `find tttt/ -name ._.DS_Store`
fi

tar cf - admin build_glm.sh READ* fetch* | (cd tttt; tar xf -)

mv tttt GLM-${GLM_VRS}
tar czf GLM-${GLM_VRS}.tar.gz GLM-${GLM_VRS}
zip -rq GLM-${GLM_VRS}.zip GLM-${GLM_VRS}
mv GLM-${GLM_VRS} tttt

if [ -d libaed-dev ] ; then
  if [ "${DO_TAG}" = "true" ] ; then
    src="libaed2-plus"
    set_tag ${src}
  fi

  zcat binaries/sources/libaed_Plus-${AED_PVRS}.tar.gz | (cd tttt; tar xf -)

  tar cf - libaed2-plus | (cd tttt; tar xf -)
  /bin/rm -rf tttt/libaed2-plus/.git*

  if [ `find tttt/ -name .DS_Store` ] ; then
    /bin/rm `find tttt/ -name .DS_Store`
  fi
  if [ `find tttt/ -name ._.DS_Store` ] ; then
    /bin/rm `find tttt/ -name ._.DS_Store`
  fi

  mv tttt GLM_Plus-${GLM_VRS}
  tar czf GLM_Plus-${GLM_VRS}.tar.gz GLM_Plus-${GLM_VRS}
  zip -rq GLM_Plus-${GLM_VRS}.zip GLM_Plus-${GLM_VRS}
  mv GLM_Plus-${GLM_VRS} tttt
fi

/bin/rm -rf tttt
mkdir -p binaries/sources
mv GLM-${GLM_VRS}.tar.gz GLM-${GLM_VRS}.zip binaries/sources
if [ -d libaed-dev ] ; then
  mv GLM_Plus-${GLM_VRS}.tar.gz GLM_Plus-${GLM_VRS}.zip binaries/sources
fi

exit 0
