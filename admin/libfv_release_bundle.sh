#!/bin/sh

CWD=`pwd`

./clean.sh # start by cleaning the respositories

if [ -d tttt ] ; then
   /bin/rm -rf tttt
fi

mkdir tttt

tar cf - libaed-water | (cd tttt; tar xf -)
/bin/rm -rf tttt/libaed-water/.git*

FV_VRS=`grep FV_AED_VERS libaed-fv/src/fv_aed.F90 | grep -w define | cut -f2 -d\"`
tar cf - libaed-fv | (cd tttt; tar xf -)
/bin/rm -rf tttt/libaed-fv/.git*

tar cf - admin build_libaed-fv.sh build.sh Notes READ* fetch* | (cd tttt; tar xf -)

mv tttt libaed_fv-${FV_VRS}
tar czf libaed_fv-${FV_VRS}.tar.gz libaed_fv-${FV_VRS}
zip -r libaed_fv-${FV_VRS}.zip libaed_fv-${FV_VRS}
mv libaed_fv-${FV_VRS} tttt

if [ -d libaed-dev ] ; then
  tar cf - libaed-riparian | (cd tttt; tar xf -)
  /bin/rm -rf tttt/libaed-riparian/.git*

  tar cf - libaed-dev | (cd tttt; tar xf -)
  /bin/rm -rf tttt/libaed-dev/.git*

  mv tttt libaed_fv_Plus-${FV_VRS}
  tar czf libaed_fv_Plus-${FV_VRS}.tar.gz libaed_fv_Plus-${FV_VRS}
  zip -r libaed_fv_Plus-${FV_VRS}.zip libaed_fv_Plus-${FV_VRS}
  mv libaed_fv_Plus-${FV_VRS} tttt
fi

/bin/rm -rf tttt
mkdir -p binaries/sources
mv libaed_fv-${FV_VRS}.tar.gz libaed_fv-${FV_VRS}.zip libaed_fv_Plus-${FV_VRS}.tar.gz libaed_fv_Plus-${FV_VRS}.zip binaries/sources

exit 0
