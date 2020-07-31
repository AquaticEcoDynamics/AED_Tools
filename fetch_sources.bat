@echo off
REM #-------------------------------------------------------------------------------
REM #  Script to fetch sources for the tools and utilities
REM #-------------------------------------------------------------------------------

setlocal EnableDelayedExpansion

SET rep_list=
SET upd_list=
SET count=0
SET GITHOST=https://github.com/AquaticEcoDynamics/

if "%1"=="" (
  REM # The default case is to just update
  SET GETAED=false
  SET GETPLOT=false
  SET GETUTIL=false
  SET GETFABM=false
  SET GET_GLM=false
  SET GETPLUS=false
  SET GETAEDFV=false
  SET upd_list=libaed-water;libaed-benthic;libaed-riparian;libaed-demo;libaed-dev;libplot;libutil;GLM;libaed-fv
)

REM #-------------------------------------------------------------------------------

:loop0
  if "%1"=="" ( GOTO :loop0end )

  if "%1"=="all" (
      SET GETAED=true
      SET GETPLOT=true
      SET GETUTIL=true
      SET GETFABM=true
      SET GET_GLM=true
      SET GETPLUS=true
      SET GETAEDFV=true
  )
  if /i "%1"=="glm" (
      SET GETAED=true
      SET GETPLOT=true
      SET GETUTIL=true
      SET GETFABM=true
      SET GET_GLM=true
  )
  if "%1"=="aed-fv" (
      SET GETAEDFV=true
      SET GETAED=true
  )
  if "%1"=="libaed"  (SET GETAED=true)
  if "%1"=="libplot" (SET GETPLOT=true)
  if "%1"=="libutil" (SET GETUTIL=true)
  if "%1"=="plus"    (SET GETPLUS=true)
  if "%1"=="fabm"    (SET GETFABM=true)

  if "%1"=="--githost" (
      SET GITHOST=%2
      shift
  )
  if "%1"=="-g" ( 
      SET GITHOST=%2
      shift
  )
  shift
  GOTO :loop0
:loop0end

if "%GET_GLM%"=="true"  ( SET rep_list=%rep_list%;GLM )
if "%GETAEDFV%"=="true" ( SET rep_list=%rep_list%;libaed-fv )
if "%GETAED%"=="true"   ( SET rep_list=%rep_list%;libaed-water;libaed-benthic;libaed-demo )
if "%GETPLUS%"=="true"  ( SET rep_list=%rep_list%;libaed-riparian;libaed-dev )
if "%GETPLOT%"=="true"  ( SET rep_list=%rep_list%;libplot )
if "%GETUTIL%"=="true"  ( SET rep_list=%rep_list%;libutil )


REM #-------------------------------------------------------------------------------
REM echo UPD_LIST: %upd_list%
REM echo REP_LIST: %rep_list%

if NOT ["%upd_list%"]==[""] (
  echo updating AED_Tools REM from `grep -w url .git\config`
  git pull

  SET count=0
  for %%r in ( %upd_list% ) do (
    if EXIST ".\%%r%\." (
      SET /A count+=1
      echo updating %%r% REM from `grep -w url %%r%\.git\config`

      cd %%r%
      git pull
      cd ..
    )
  )
) else ( if NOT ["%rep_list%"]==[""] (
  for %%r in ( %rep_list% ) do (
    SET /A count+=1
    call :fetch_it %%r%
  )
))

REM #-------------------------------------------------------------------------------

if "%GETFABM%"=="true" (
  REM  Test for cmake installed
  REM  if errorlevel 1 is true for errorlevel >= 1 so this works
  REM  curiously, if %errorlevel% neq 0 doesn't work
  cmake --version > NUL 2>&1
  if errorlevel 1 (
     echo WARNING
     echo WARNING   FABM requires you have cmake installed in order to build
     echo WARNING   It seems you do not have cmake installed
     echo WARNING
  )
  SET /A count+=1
  if NOT EXIST ".\fabm-git\." (
    echo ====================================================
    echo fetching fabm from git://git.code.sf.net/p/fabm/code
    git clone git://git.code.sf.net/p/fabm/code fabm-git
  )
)

REM #-------------------------------------------------------------------------------
if !count! EQU 0 (
  @echo "There do not seem to be any repositories requested or present"
  @echo "Usage :"
  @echo "  fetch_sources.bat [-g <githost>] <repo>"
  @echo ""
  @echo "where <repo> can be one or more of :"
  @echo "  glm     : get glm [and it's dependancies]"
  @echo "  libaed  : fetch the libaed sources"
  @echo "  libplot : fetch the libplot sources"
  @echo "  libutil : fetch the libutil sources"
  @echo "  plus    : fetch the libaed-* plus sources (private repository)"
  @echo "  aed-fv  : fetch the libaed-fv sources"
  @echo "  fabm    : fetch the fabm sources (possible dependancy for glm)"
  @echo ""
  @echo "  all     : fetch them all"
  @echo ""
  @echo "  -g|--githost <githost> : allows you to specify a different githost"
  @echo "          The default is https://github.com/AquaticEcoDynamics/"
)

exit /b 0

#-------------------------------------------------------------------------------

:fetch_it
  SET src=%1

  echo ====================================================
  echo fetching %src%

  if EXIST %src%\. (
    echo updating %src% REM from `grep -w url %src%\.git\config`

    cd %src%
    git pull
    cd ..
  ) else (
    echo fetching %src% from %GITHOST%%src%

    git clone %GITHOST%%src%
  )
exit /b
