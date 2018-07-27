Add-Type -assembly System.Security

$TopLevelFolder=$args[0] #Typically C:\DataImport\ADT2Schedule, subfolders must match to Practice subsites in SharePoint
$promptForCredentials=[System.Convert]::ToBoolean($args[1])

$user = [System.Security.Principal.WindowsIdentity]::GetCurrent().Name

$Credential = $null

$CurrentDir = Resolve-Path .
$logfile=$CurrentDir.Path + "\ConvertADTRecordsToCSV.log"
Start-Transcript $logfile

$path = ".\password.bin"

# Retrieve and decrypt password
if (!$promptForCredentials){
	if (-not (Test-Path $path)) { 
		$message = "password file " + $path + " not found, run EncryptPassword first"
		echo $message
		exit 1 
	}

	$password = Get-Content $path | ConvertTo-SecureString 
	$Credential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $user, $password
} else {
	$Credential = Get-Credential -Credential $user
}


function Convert-FilesToScheduleCSV([string] $Source, [string] $Dest) {

cd $CurrentDir

Write-Host "Converting ADT records to CSV: Source = $Source, Dest = $Dest"

. ./ConvertADTRecordsToCSV.exe $Source $Dest 

}

function Delete-Files([string] $Source) {

Write-Host "Deleting ADT records from $Source"
cd $Source
Get-Childitem -File | Foreach-Object {Remove-Item $_.FullName}
cd $CurrentDir
}


cd $TopLevelFolder
Get-ChildItem -Directory | foreach {
	$Source = $TopLevelFolder + "\" + $_
	$Dest = $TopLevelFolder + "/../CSV" + "/" + $_ 

	Convert-FilesToScheduleCSV $Source $Dest
	
	Delete-Files $Source
}

Write-Host "Done..." -ForegroundColor Magenta
Stop-Transcript 


