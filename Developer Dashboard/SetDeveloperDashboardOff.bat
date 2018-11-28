@echo off
rem SET STSADM="c:\Program Files\Common Files\Microsoft Shared\Web Server Extensions\15\bin\STSADM.EXE"
rem stsadm -o setproperty -pn Developer-Dashboard -pv Off
rem stsadm -o getproperty -pn Developer-Dashboard 
call RunPS.bat SetDeveloperDashboardOff.ps1
pause