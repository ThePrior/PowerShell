#Powershell Script to delete AuditData table records.

$currentDate = Get-Date
 #Write-Host $currentDate

#subtract days from today to sync up to the last day we want to keep in the table
 $constantNumberDays = -535

$newDateToDelete = $currentDate.AddDays($constantNumberDays)

$newDateString = ‘{0:yyyyMMdd}’ -f $newDateToDelete
 #Write-Host $newDateString

$newSTSADM1 = "stsadm -o trimauditlog -date"
$newSTSADM2 = " -databasename WSS_Content"
$newSTSADMFinal = "$newSTSADM1$newDateString$newSTSADM2"
invoke-expression  "$newSTSADMFinal"