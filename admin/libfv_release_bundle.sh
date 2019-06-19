#!/bin/sh

CWD=`pwd`

./clean.sh # start by cleaning the respositories

if [ -d tttt ] ; then
   /bin/rm -rf tttt
fi

mkdir tttt

tar cf - libaed2 | (cd tttt; tar xf -)
/bin/rm -rf tttt/libaed2/.git*

FV_VRS=`grep FV_AED_VERS libfvaed2/src/fv_aed2.F90 | grep -w define | cut -f2 -d\"`
tar cf - libfvaed2 | (cd tttt; tar xf -)
/bin/rm -rf tttt/libfvaed2/.git*

tar cf - admin build_libfvaed2.sh build.sh Notes READ* fetch* | (cd tttt; tar xf -)

mv tttt libfvaed2-${FV_VRS}
tar czf libfvaed2-${FV_VRS}.tar.gz libfvaed2-${FV_VRS}
zip -r libfvaed2-${FV_VRS}.zip libfvaed2-${FV_VRS}
mv libfvaed2-${FV_VRS} tttt

if [ -d libaed2-plus ] ; then
  tar cf - libaed2-plus | (cd tttt; tar xf -)
  /bin/rm -rf tttt/libaed2-plus/.git*

  mv tttt libfvaed2_Plus-${FV_VRS}
  tar czf libfvaed2_Plus-${FV_VRS}.tar.gz libfvaed2_Plus-${FV_VRS}
  zip -r libfvaed2_Plus-${FV_VRS}.zip libfvaed2_Plus-${FV_VRS}
  mv libfvaed2_Plus-${FV_VRS} tttt
fi

/bin/rm -rf tttt

exit 0
