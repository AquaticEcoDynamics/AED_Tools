
# These if we just need fortran on ubuntu
#export NETCDFV=4.7.3
#export NETCDFFV=4.5.2

# this for building older tuflow
#export NETCDFFV=4.4.5

# These if we need both
export NETCDFV=4.9.2
export NETCDFFV=4.6.1

export MPICHV=4.2.3
export OMPIMAJ=5.0
export OMPIV=5.0.6

#-----------------------------------------------------------

export NETCDF=netcdf-c-${NETCDFV}
export NETCDFF=netcdf-fortran-${NETCDFFV}
export MPICH=mpich-${MPICHV}
export OMPI=openmpi-${OMPIV}

#-----------------------------------------------------------

export ZLIBV=1.3.1
export FRREETYPE2V=2.13.3
export JPEGV=9f
export LIBPNGV=1.6.44
export GD=gd-2.3.3

#-----------------------------------------------------------

export ZLIB=zlib-${ZLIBV}
export FREETYPE2=freetype-${FRREETYPE2V}
export JPEG=jpegsrc.v${JPEGV}
export LIBPNG=libpng-${LIBPNGV}
export LIBGD=lib${GD}

#-----------------------------------------------------------

#export CURLV=8.11.0
export CURLV=8.5.0
export SZIPV=2.1.1
#export LIBAECV=v1.1.3
export LIBAECV=v1.1.2
export HDF5V=1.14.5

#-----------------------------------------------------------

export CURL=curl-${CURLV}
export LIBAEC=libaec-${LIBAECV}
export HDF5=hdf5-${HDF5V}

#-----------------------------------------------------------
