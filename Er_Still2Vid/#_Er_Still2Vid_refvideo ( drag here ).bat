@echo off
setlocal EnableExtensions

set "SCRIPT=%~dp0#_Er_Still2Vid_refvideo.ps1"
set "ARGFILE=%TEMP%\still2vid_args_%RANDOM%%RANDOM%.txt"
type nul > "%ARGFILE%"

rem -- เก็บทุกพาธที่ลากมา ลงไฟล์ชั่วคราว (รองรับหลายไฟล์/โฟลเดอร์/พาธยาว) --
:collect
if "%~1"=="" goto run
>> "%ARGFILE%" echo %~f1
shift
goto collect

:run
"%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoProfile -ExecutionPolicy Bypass -Sta -File "%SCRIPT%" -ArgFile "%ARGFILE%"
del /q "%ARGFILE%" >nul 2>nul
endlocal
