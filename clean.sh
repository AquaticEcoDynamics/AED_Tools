#!/bin/bash

cd GLM
./clean_glm.sh
cd ../fabm-git
/bin/rm -rf build
cd ../libutil
make distclean
cd ../libplot
make distclean
cd ../libaed2
make distclean

exit 0
