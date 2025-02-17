for dir in gfortran ifort ifx ; do

  cd $dir
  /bin/rm -rf src/netcdf-fortran-4.4.5
  /bin/rm -rf src/netcdf-fortran-4.6.1
  /bin/rm -rf include bin lib share
  cd ..

done
