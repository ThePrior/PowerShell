@echo off
setlocal
pushd.

if "%1" EQU "" echo No powershell script specified && goto Usage
set webAppUrl=%1

cd /d %~dp0
powershell.exe -executionpolicy unrestricted -command  ".\RunPS.ps1" %1

goto Done

:Usage

echo Usage: RunPS.bat script.ps1

:Done
popd
