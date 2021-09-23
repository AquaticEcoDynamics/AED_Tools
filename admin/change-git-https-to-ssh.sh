#!/bin/sh
#-------------------------------------------------------------------------------
#  Script to change from https to ssh
#-------------------------------------------------------------------------------

GITHOST=git@github.com:AquaticEcoDynamics/


git remote set-url origin ${GITHOST}AED_Tools

#-------------------------------------------------------------------------------

for src in libaed-water libaed-benthic libaed-riparian libaed-demo libaed-dev libplot libutil libaed-fv libaed2 libaed2-plus GLM ; do
  if [ -d $src ] ; then
    cd $src
    echo set git remote for $src
    git remote set-url origin ${GITHOST}${src}
    git remote -v
    cd ..
  fi
done

exit 0
