if (-not (Get-PSSnapin | Where {$_.Name -eq "Microsoft.SharePoint.PowerShell"})) { 
    Add-PSSnapin Microsoft.SharePoint.Powershell; 
}

$CurrentDir = Resolve-Path .
$logfile=$CurrentDir.Path + "\DEV_BackupUPS.log"

Start-Transcript $logfile

Backup-SPFarm -Directory "\\rvn-sps-sql21\SQLBackup\Farm Backup\DEV" -BackupMethod Full -Item "Farm\Shared Services\Shared Services Applications\User Profile Service Application" -Verbose

Stop-Transcript