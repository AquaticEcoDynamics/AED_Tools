# ===========================================================================

echo "====== building $MPICH"

\rm -rf $MPICH
tar xzf $MPICH.tar.gz
if [ ! -d $MPICH ] ; then
  echo cant unpack $MPICH.tar.gz
  exit 1
fi
cd $MPICH

if [ "$OSNAME" = "Darwin" ] ; then
  # on macos we'll need --with-libevent=/opt/homebrew
  EXTRA_CONF="--with-libevent=/opt/homebrew"
else
  EXTRA_CONF=""
fi

./configure --prefix=${FINALDIR} --enable-shared=no ${EXTRA_CONF}
if [ $? = 0 ] ; then
  make
  if [ $? = 0 ] ; then
    make install
  else
    echo '****' build failed for $MPICH
    exit 1
  fi
else
  echo '****' config failed for $MPICH
  exit 1
fi
cd ..
echo '****************' done building in $MPICH

cd $CWD
summary $MPICH
