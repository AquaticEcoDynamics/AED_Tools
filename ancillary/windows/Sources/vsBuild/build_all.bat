@echo off

for /f "usebackq delims=#" %%a in (`"%programfiles(x86)%\Microsoft Visual Studio\Installer\vswhere" -latest -property installationPath`) do set VS_BASE_PATH=%%a\Common7

call "%VS_BASE_PATH%\Tools\VsDevCmd.bat" -arch=amd64

"%VS_BASE_PATH%\IDE\devenv" all_libs.sln /Build "Release|x64"
