#!/bin/sh

export OUTFILE="ReleaseInfo.txt"
export MAINLIST="GLM libplot libutil libaed-water libaed-benthic libaed-demo libaed2"
export PLUSLIST="libaed-riparian libaed-dev libaed2-plus"
export GITPATH=".git"

extract_vers () {
# export RPO=`cat .git/config | grep -w url | rev | cut -d'/' -f 1 | rev`
# mingw doesnt have rev, so do it this way.
  export RPO=`cat ${GITPATH}/config | grep -w url | tr '/' '\n' | tail -1`
  export VRS=`cat ${GITPATH}/ORIG_HEAD | cut -c -7`
  echo "$VRS $RPO"
}

do_list () {
  for src in $* ; do
    if [ -d $src ] ; then
      cd $src
        extract_vers
      cd ..
    fi
  done
}

do_it () {
  echo "This build is produced from the following git points :"
  echo
  extract_vers
  do_list ${MAINLIST}

  # For the PLUS versions :
  echo
  echo "The plus version also has :"
  echo
  do_list ${PLUSLIST}
}

do_it #> ${OUTFILE}

exit 0
