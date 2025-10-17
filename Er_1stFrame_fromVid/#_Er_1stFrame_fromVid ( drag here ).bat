@echo off
setlocal EnableExtensions EnableDelayedExpansion

rem ============================================
rem  Author : Er+GPT
rem  Function: Extract first frame as _0000.png
rem  ffmpeg  : ..\ffmpeg.exe (fallback: .\ffmpeg.exe or PATH)
rem  env     : conda activate wan2gp (if available)
rem  Note    : auto-close if no errors
rem ============================================

rem --- lock working directory to this .bat's location ---
cd /d "%~dp0"

set "SCRIPT_DIR=%~dp0"
set "FFMPEG_BIN=..\ffmpeg.exe"
set "CONDA_ENV=wan2gp"
set "HAS_ERROR=0"

rem --- ffmpeg path check + fallback ---
if not exist "%FFMPEG_BIN%" (
    if exist ".\ffmpeg.exe" (
        set "FFMPEG_BIN=.\ffmpeg.exe"
    ) else (
        for /f "delims=" %%P in ('where ffmpeg.exe 2^>nul') do set "FFMPEG_BIN=%%~fP"
    )
)
if not exist "%FFMPEG_BIN%" (
    echo [ERROR] ffmpeg not found at "..\ffmpeg.exe", ".\ffmpeg.exe", or in PATH.
    echo Please place ffmpeg.exe one level up from this .bat, or set PATH manually.
    pause
    exit /b 1
)

rem --- check if conda exists and activate ---
where /q conda
if %errorlevel%==0 (
    call conda activate "%CONDA_ENV%" >nul 2>&1
) else (
    echo [WARN] conda not found in PATH, skipping activation.
)

rem --- require input files ---
if "%~1"=="" (
    echo [INFO] Drag and drop video files onto this .bat to extract first frame.
    pause
    exit /b 0
)

rem --- main loop for dropped files ---
for %%F in (%*) do (
    if exist "%%~fF" (
        set "BASE=%%~nF"
        set "OUT=%SCRIPT_DIR%!BASE!_0000.png"

        if exist "!OUT!" (
            set /a N=1
            :find_next
            set "OUT=%SCRIPT_DIR%!BASE!_0000(!N!).png"
            if exist "!OUT!" (
                set /a N+=1
                goto find_next
            )
        )

        "%FFMPEG_BIN%" -hide_banner -loglevel error -y -i "%%~fF" -frames:v 1 "!OUT!"
        if errorlevel 1 (
            echo [FAIL] %%~nxF
            set "HAS_ERROR=1"
        )
    ) else (
        echo [SKIP] File not found: "%%~fF"
        set "HAS_ERROR=1"
    )
)

if "%HAS_ERROR%"=="0" (
    rem --- no errors, exit silently ---
    exit /b 0
) else (
    echo.
    echo One or more files failed. Check above messages.
    pause
    exit /b 1
)
