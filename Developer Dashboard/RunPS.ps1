Add-PsSnapin Microsoft.SharePoint.PowerShell

$script=$args[0]

$CurrentDir = Resolve-Path .

& .\$script

Remove-PsSnapin Microsoft.SharePoint.PowerShell
