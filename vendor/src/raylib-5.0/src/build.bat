@echo off
setlocal

:: Make sure we're running in the same directory as the bat script
cd /D "%~dp0"

pushd ..\..\..\
set vendor_root=%CD%
popd
echo vendor root is %vendor_root%

:: --- Usage Notes ------------------------------------------------
::
:: This is a central build script for the raylib project, for use in
:: Windows development environments. It takes a list of simple alphanumeric-
:: only arguments which control (a) what is built, (b) which compiler & linker
:: are used, and (c) extra high-level build options. By default, if no options
:: are passed, then the main "raylib" graphical debugger is built.
::
:: Below is a non-exhaustive list of possible ways to use the script:
:: `build raylib`
:: `build raylib clang`
:: `build raylib release`
:: `build raylib asan telemetry`
::
:: For a full list of possible build targets and their build command lines,
:: search for @build_targets in this file.
::itizer
:: - `telemetry`: enable RAD telemetry profiling support

:: --- Unpack Arguments -------------------------------------------------------
for %%a in (%*) do set "%%a=1"
if not "%msvc%"=="1" if not "%clang%"=="1" set msvc=1
if not "%release%"=="1" set debug=1
if "%debug%"=="1"   set release=0 && echo [debug mode]
if "%release%"=="1" set debug=0 && echo [release mode]
if "%msvc%"=="1"    set clang=0 && echo [msvc compile]
if "%clang%"=="1"   set msvc=0 && echo [clang compile]
if "%~1"==""                     echo [default mode, assuming `raylib` build] && set raddbg=1
if "%~1"=="release" if "%~2"=="" echo [default mode, assuming `raylib` build] && set raddbg=1

:: --- Unpack Command Line Build Arguments ------------------------------------
set auto_compile_flags=
if "%telemetry%"=="1" set auto_compile_flags=%auto_compile_flags% -DPROFILE_TELEMETRY=1 && echo [telemetry profiling enabled]
if "%asan%"=="1"      set auto_compile_flags=%auto_compile_flags% -fsanitize=address && echo [asan enabled]

:: --- Compile/Link Line Definitions ------------------------------------------
set cl_common=     /I..\src\ /I..\local\ /nologo /FC /Z7
set clang_common=  -I..\src\ -I..\local\ -gcodeview -fdiagnostics-absolute-paths -Wall -Wno-unknown-warning-option -Wno-missing-braces -Wno-unused-function -Wno-writable-strings -Wno-unused-value -Wno-unused-variable -Wno-unused-local-typedef -Wno-deprecated-register -Wno-deprecated-declarations -Wno-unused-but-set-variable -Wno-single-bit-bitfield-constant-conversion -Wno-compare-distinct-pointer-types -Wno-initializer-overrides -Wno-incompatible-pointer-types-discards-qualifiers -Xclang -flto-visibility-public-std -D_USE_MATH_DEFINES -Dstrdup=_strdup -Dgnu_printf=printf -ferror-limit=10000
set cl_debug=      call cl /Od /Ob1 /DBUILD_DEBUG=1 %cl_common% %auto_compile_flags%
set cl_release=    call cl /O2 /DBUILD_DEBUG=0 %cl_common% %auto_compile_flags%
set clang_debug=   call clang -g -O0 -DBUILD_DEBUG=1 %clang_common% %auto_compile_flags%
set clang_release= call clang -g -O2 -DBUILD_DEBUG=0 %clang_common% %auto_compile_flags%
set cl_link=       /link /MANIFEST:EMBED /INCREMENTAL:NO /pdbaltpath:%%%%_PDB%%%%
set clang_link=    -fuse-ld=lld -Xlinker /MANIFEST:EMBED -Xlinker /pdbaltpath:%%%%_PDB%%%%
set cl_out=        /out:
set clang_out=     -o

:: --- Per-Build Settings -----------------------------------------------------
set link_dll=-DLL
if "%msvc%"=="1"    set only_compile=/c
if "%clang%"=="1"   set only_compile=-c
if "%msvc%"=="1"    set EHsc=/EHsc
if "%clang%"=="1"   set EHsc=
if "%msvc%"=="1"    set no_aslr=/DYNAMICBASE:NO
if "%clang%"=="1"   set no_aslr=-Wl,/DYNAMICBASE:NO
if "%msvc%"=="1"    set rc=call rc
if "%clang%"=="1"   set rc=call llvm-rc

:: --- Choose Compile/Link Lines ----------------------------------------------
if "%msvc%"=="1"      set compile_debug=%cl_debug%
if "%msvc%"=="1"      set compile_release=%cl_release%
if "%msvc%"=="1"      set compile_link=%cl_link%
if "%msvc%"=="1"      set out=%cl_out%
if "%clang%"=="1"     set compile_debug=%clang_debug%
if "%clang%"=="1"     set compile_release=%clang_release%
if "%clang%"=="1"     set compile_link=%clang_link%
if "%clang%"=="1"     set out=%clang_out%
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
if "%raylib%"=="1" %cl_lib% *.obj /out:..\lib\raylib.lib || exit /b 1
echo running cp ..\raylib.h %vendor_root%\include\raylib.h
if "%raylib%"=="1" copy ..\raylib.h %vendor_root%\include\raylib.h || exit /b 1
echo running cp ..\lib\raylib.lib %vendor_root%\lib\raylib.lib 
if "%raylib%"=="1" copy ..\lib\raylib.lib %vendor_root%\lib\raylib.lib || exit /b 1
popd

:: --- Unset ------------------------------------------------------------------
for %%a in (%*) do set "%%a=0"
set raylib=
set compile=
set compile_link=
set out=
set msvc=
set debug=
set release=

:: --- Warn On No Builds ------------------------------------------------------
if "%didbuild%"=="" (
  echo [WARNING] no valid build target specified; must use build target names as arguments to this script, like `build raylib`.
  exit /b 1
)

