Add-PsSnapin Microsoft.SharePoint.PowerShell

try 
{
	$CurrentDir = Resolve-Path .
	$logfile=$CurrentDir.Path + "\PROD_BackupFarmConfigOnly.log"
	$logfile
	
	Start-Transcript $logfile
	
    Backup-SPFarm -Directory "\\rvn-sps-sql21\SQLBackup\Farm Backup\PROD" -BackupMethod Full -ConfigurationOnly -ErrorAction Stop
} 
catch 
{
	Write-Host $error[0]
    exit 1
}

Stop-Transcript

exit 0
