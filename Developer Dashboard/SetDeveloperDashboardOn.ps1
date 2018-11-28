$svc = [Microsoft.SharePoint.Administration.SPWebService]::ContentService
$dds = $svc.DeveloperDashboardSettings
$dds.DisplayLevel = "On"
$dds.Update()