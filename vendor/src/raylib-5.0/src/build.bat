@echo off
setlocal

:: Make sure we're running in the same directory as the bat script
cd /D "%~dp0"

pushd ..\..\..\
set vendor_root=%CD%
popd
echo vendor root is %vendor_root%

:: --- Unpack Arguments -------------------------------------------------------
for %%a in (%*) do set "%%a=1"
if not "%release%"=="1" set debug=1
if "%debug%"=="1"   set release=0 && echo [debug mode]
if "%release%"=="1" set debug=0 && echo [release mode]
if "%~1"==""                     echo [default mode, assuming `cardiograph` build]
if "%~1"=="release" if "%~2"=="" echo [default mode, assuming `cardiograph` build]

:: --- Compile/Link Line Definitions ------------------------------------------
set compile_common=     /I..\src\ /I%vendor_root%\include /nologo /FC /Z7
set compile_debug=      call cl /Od /Ob1 /DBUILD_DEBUG=1 %compile_common%
set compile_release=    call cl /O2 /DBUILD_DEBUG=0 %compile_common%
set compile_link=       /link /MANIFEST:EMBED /INCREMENTAL:NO /pdbaltpath:%%%%_PDB%%%% /SUBSYSTEM:CONSOLE
set out=        /out:

:: --- Choose Compile/Link Lines ----------------------------------------------
if "%debug%"=="1"     set compile=%compile_debug%
if "%release%"=="1"   set compile=%compile_release%

:: --- Choose Lib Lines ----------------------------------------------
set cl_lib=call lib 

:: --- Prep Directories -------------------------------------------------------
if not exist build mkdir build
if not exist lib mkdir lib

pushd build
echo running %compile% /c /DPLATFORM_DESKTOP /DGRAPHICS_API_OPENGL_33  %~dp0\*.c /I ../external\glfw\include
if "%raylib%"=="1" set didbuild=1 && %compile% /c /DPLATFORM_DESKTOP /DGRAPHICS_API_OPENGL_33 %~dp0\*.c /I ../external\glfw\include || exit /b 1
echo running %cl_lib% *.obj /out:..\lib\raylib.lib 
%cl_lib% *.obj /out:..\lib\raylib.lib || exit /b 1
echo running cp ..\raylib.h %vendor_root%\include\raylib.h
copy ..\raylib.h %vendor_root%\include\raylib.h || exit /b 1
echo running cp ..\lib\raylib.lib %vendor_root%\lib\raylib.lib 
copy ..\lib\raylib.lib %vendor_root%\lib\raylib.lib || exit /b 1
popd

:: --- Unset ------------------------------------------------------------------
for %%a in (%*) do set "%%a=0"
set raylib=
set compile=
set compile_link=
set out=
set debug=
set release=
