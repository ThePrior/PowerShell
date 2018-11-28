if (-not (Get-PSSnapin | Where {$_.Name -eq "Microsoft.SharePoint.PowerShell"})) { 
    Add-PSSnapin Microsoft.SharePoint.Powershell; 
}

$CurrentDir = Resolve-Path .
$logfile=$CurrentDir.Path + "\DEV_RestorePS.log"

Start-Transcript $logfile

Restore-SPFarm -Directory "\\rvn-sps-sql21\SQLBackup\Farm Backup\DEV"  -Item "Farm\Shared Services\Shared Services Applications\User Profile Service Application" -RestoreMethod Overwrite -BackupId 2b81ea5e-bf55-4fcb-9b41-1da8def70b84 -Verbose

Stop-Transcript