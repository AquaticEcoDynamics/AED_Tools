@rem Script to build the szip library

set LibName=szip
set VersNum=-2.1.1

@echo off

if "%1%"=="" ( echo no configuration type given
               exit /B 5 )
if "%2%"=="" ( echo no platform type given
               exit /B 5 )

set Configuration=%1%
set Platform=%2%

set BaseDir=%LibName%%VersNum%

@rem Check env var VisualStudioVersion
if "%VisualStudioVersion%"=="14.0" (
  set GV=14 2015
) else if "%VisualStudioVersion%"=="15.0" (
  set GV=15 2017
) else if "%VisualStudioVersion%"=="16.0" (
  set GV=16 2019
) else if "%VisualStudioVersion%"=="16.0" (
  set GV=16 2019
) else (
  echo Unknown Visual Studio version
)

set Generator="Visual Studio %GV%"

set startdir=%cd%
set prevdir=%cd%

:loop1
   if EXIST ".\%BaseDir%\." ( goto :done1 )
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

chdir ..
set RootDir=%cd%
set SrcDir=%RootDir%\Sources\%BaseDir%

echo Current Directory %startdir%

chdir %startdir%
if not EXIST ".\%Platform%-%Configuration%\." ( mkdir "%Platform%-%Configuration%" )
set build_dir=%startdir%\%Platform%-%Configuration%\%LibName%
echo Build directory: %build_dir%
if not EXIST ".\%build_dir%\." ( mkdir "%build_dir%" )
chdir "%build_dir%"

set install_prefix=%RootDir%\%Platform%-%Configuration%
echo Install directory: %install_prefix%

echo Sources in %SrcDir%

@echo on

cmake "%SrcDir%" ^
      -G %Generator% ^
      -A %Platform% ^
      -DCMAKE_CXX_FLAGS="-I%install_prefix%\include" ^
      -DCMAKE_VS_PLATFORM_NAME=%Platform% ^
      -DCMAKE_CONFIGURATION_TYPES="Debug;Release" ^
      -DCMAKE_INSTALL_PREFIX="%install_prefix%"

cmake --build . --clean-first --config %Configuration% --target INSTALL

@chdir %startdir%

exit /B 0
