@echo off
set "SCRIPT=%~dp0#_Er_Still2Vid.ps1"
"%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoProfile -ExecutionPolicy Bypass -Sta -File "%SCRIPT%" %*
