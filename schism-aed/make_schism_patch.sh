#!/bin/bash

if -d [ schism ] ; then
  cd schism
  git diff > ../schism-aed/aed-schism.xdiff
  git log | head -1 | cut -d\  -f2 > ../schism-aed/gitlog-schism
  cd ..
fi
