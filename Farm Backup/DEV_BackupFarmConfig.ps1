Add-PsSnapin Microsoft.SharePoint.PowerShell

Backup-SPFarm -Directory "\\rvn-sps-sql21\SQLBackup\Farm Backup\DEV" -Backup Method Full -ConfigurationOnly -Verbose
