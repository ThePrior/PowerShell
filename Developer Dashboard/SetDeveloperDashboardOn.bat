@echo off
echo "REMEMBER: Must provision Usage and Health service for DD to work  
rem SET STSADM="c:\Program Files\Common Files\Microsoft Shared\Web Server Extensions\15\bin\STSADM.EXE"
rem stsadm -o setproperty -pn Developer-Dashboard -pv On
rem stsadm -o getproperty -pn Developer-Dashboard 
call RunPS.bat SetDeveloperDashboardOn.ps1
pause