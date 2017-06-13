@rem Script to build the fabm library for glm

@echo off

if "%1%"=="" ( echo no configuration type given
               exit /B 5 )
if "%2%"=="" ( echo no platform type given
               exit /B 5 )

set Configuration=%1%
set Platform=%2%

echo %Platform%-%Configuration%

@rem set Configuration=Release
@rem set Configuration=Debug
@rem set Platform=x64
@rem set Platform=Win32


set startdir=%cd%
set build_dir=%startdir%\tmp
echo Current Directory %startdir%

set prevdir=%cd%

:loop1
   if EXIST "fabm-git\." ( goto :done1 )
   cd ..
   rem echo now in dir %cd%
   rem echo prev in dir %prevdir%
   if "%prevdir%"=="%cd%" (
      rem chdir did nothing - probably at the top of the tree
      echo Cannot find source tree
      chdir %startdir%
      exit /B 6
   )
   set prevdir=%cd%
   goto :loop1

:done1

chdir fabm-git
set FABM_BASE=%cd%
chdir %old%

echo Build directory:
echo %build_dir%
if not EXIST "%build_dir%\." ( mkdir "%build_dir%" )
chdir "%build_dir%"

echo Base directories:
echo %FABM_BASE%

echo Default Fortran compiler is ifort
set compiler=ifort

echo Install directory:
set install_prefix=%startdir%\%Platform%-%Configuration%
echo %install_prefix%

set host=glm
set FABM_HOST=%host%
if not EXIST "%host%\." ( mkdir "%host%" )
chdir "%host%"

@echo on

cmake "%FABM_BASE%\src" ^
      -DFABM_EMBED_VERSION=on ^
      -DFABM_HOST=%host% ^
      -DCMAKE_Fortran_COMPILER=%compiler% ^
      -DCMAKE_VS_PLATFORM_NAME=%Platform% ^
      -DCMAKE_CONFIGURATION_TYPES="Debug;Release" ^
      -DCMAKE_INSTALL_PREFIX="%install_prefix%"

@rem pause

@rem cmake --build . --clean-first --config "%Configuration%" --target INSTALL
cmake --build . --clean-first --config %Configuration% --target INSTALL

@rem pause

@chdir %startdir%

