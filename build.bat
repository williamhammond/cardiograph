@echo off
setlocal

:: Make sure we're running in the same directory as the bat script
cd /D "%~dp0"

pushd .\vendor
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
set compile_link=       /link /MANIFEST:EMBED /INCREMENTAL:NO /pdbaltpath:%%%%_PDB%%%% /SUBSYSTEM:CONSOLE %vendor_root%\lib\raylib.lib gdi32.lib User32.lib shell32.lib  winmm.lib
set out=        /out:

:: --- Choose Compile/Link Lines ----------------------------------------------
if "%debug%"=="1"     set compile=%compile_debug%
if "%release%"=="1"   set compile=%compile_release%

:: --- Prep Directories -------------------------------------------------------
if not exist build mkdir build

:: --- Build Everything (@build_targets) --------------------------------------
pushd build
echo %compile% ..\src\main.cpp %compile_link% %out%cardiograph.exe 
%compile% ..\src\main.cpp %compile_link% %out%cardiograph.exe || exit /b 1
popd

:: --- Unset ------------------------------------------------------------------
for %%a in (%*) do set "%%a=0"
set cardiograph=
set compile=
set compile_link=
set out=
set debug=
set release=

