set Configuration=%1%
set Platform=%2%
set DestDir="..\..\%Platform%-%Configuration%"
echo DestDir is %DestDir%
if not EXIST "%DestDir%" ( mkdir %DestDir% )
if not EXIST "%DestDir%\include" ( mkdir %DestDir%\include )

copy ..\freetype-2.12.1\include\ft2build.h %DestDir%\include
md %DestDir%\include\freetype
md %DestDir%\include\freetype\config
copy ..\freetype-2.12.1\include\freetype\config\*.h %DestDir%\include\freetype\config
REM copy ..\freetype-2.12.1\include\freetype\freetype.h %DestDir%\include\freetype
REM copy ..\freetype-2.12.1\include\freetype\fterrdef.h %DestDir%\include\freetype
REM copy ..\freetype-2.12.1\include\freetype\fterrors.h %DestDir%\include\freetype
REM copy ..\freetype-2.12.1\include\freetype\ftimage.h %DestDir%\include\freetype
REM copy ..\freetype-2.12.1\include\freetype\ftglyph.h %DestDir%\include\freetype
REM copy ..\freetype-2.12.1\include\freetype\ftmoderr.h %DestDir%\include\freetype
REM copy ..\freetype-2.12.1\include\freetype\ftsizes.h %DestDir%\include\freetype
REM copy ..\freetype-2.12.1\include\freetype\ftsystem.h %DestDir%\include\freetype
REM copy ..\freetype-2.12.1\include\freetype\fttypes.h %DestDir%\include\freetype

copy ..\freetype-2.12.1\include\freetype\*.h %DestDir%\include\freetype
