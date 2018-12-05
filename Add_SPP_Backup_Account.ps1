Add-PsSnapin Microsoft.SharePoint.PowerShell

ForEach ($db in Get-SPDatabase) {Add-SPShellAdmin -Username awwt\spp_backup -Database $db}

