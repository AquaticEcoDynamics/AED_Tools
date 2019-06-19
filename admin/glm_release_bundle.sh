#!/bin/sh

CWD=`pwd`

./clean.sh # start by cleaning the respositories

if [ -d tttt ] ; then
   /bin/rm -rf tttt
fi

mkdir tttt

tar cf - libplot | (cd tttt; tar xf -)
/bin/rm -rf tttt/libplot/.git*

tar cf - libutil | (cd tttt; tar xf -)
/bin/rm -rf tttt/libutil/.git*

tar cf - libaed2 | (cd tttt; tar xf -)
/bin/rm -rf tttt/libaed2/.git*

GLM_VRS=`grep GLM_VERSION GLM/src/glm.h | cut -f2 -d\"`
tar cf - GLM | (cd tttt; tar xf -)
/bin/rm -rf tttt/GLM/.git*

tar cf - admin build_glm.sh build.sh Notes READ* fetch* | (cd tttt; tar xf -)

mv tttt GLM-${GLM_VRS}
tar czf GLM-${GLM_VRS}.tar.gz GLM-${GLM_VRS}
zip -r GLM-${GLM_VRS}.zip GLM-${GLM_VRS}
mv GLM-${GLM_VRS} tttt

if [ -d libaed2-plus ] ; then
  tar cf - libaed2-plus | (cd tttt; tar xf -)
  /bin/rm -rf tttt/libaed2-plus/.git*

  mv tttt GLM_Plus-${GLM_VRS}
  tar czf GLM_Plus-${GLM_VRS}.tar.gz GLM_Plus-${GLM_VRS}
  zip -r GLM_Plus-${GLM_VRS}.zip GLM_Plus-${GLM_VRS}
  mv GLM_Plus-${GLM_VRS} tttt
fi

/bin/rm -rf tttt

exit 0
