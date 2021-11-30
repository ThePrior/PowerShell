cls

cd $PSScriptRoot

$global:scriptName = $MyInvocation.MyCommand.Name

#$Drive = "H:" # Mapped to \\RVN00-WD-STORE\WinDIP_Archive$\WinDIP Extracts
$Drive = "I:" # Mapped to \\RVN00-WD-TEST\WinDIP Extracts

#$global:topLevelFolderName = "01.01.2017-31.12.2017"
#$global:topLevelFolderName = "01.01.2016-31.12.2016"
#$global:topLevelFolderName = "01.01.2015-31.12.2015"
#$global:topLevelFolderName = "01.01.2014-31.01.2014"
#$global:topLevelFolderName = "MFDs (mixed extensions)"
$global:topLevelFolderName = "MFDs (same extensions)"


$logName = "$global:scriptName-$global:topLevelFolderName"

$timeStamp = $(get-date).ToString('yyyy-MM-ddTHH-mm-ss')

Start-Transcript -Path ".\Transcripts\$logName-$timeStamp.txt"

. ..\..\Common\Common-Logging.ps1
. ..\..\Common\Common-Reporting.ps1
. ..\..\Common\Common-DateTime.ps1

. .\Upload-Types.ps1
#. .\Report-PendingDeletions.ps1

. .\Upload-Categories.ps1
. .\Process-XmlFile.ps1 

. .\Do-ProcessFolder.ps1 

$folderName = $null
#$folderName = "H:\\01.01.2016-31.12.2016\AWP\Contractual Documents\21_10_2016\f8d3d0f1-e9ee-428b-836e-48d500e4f788"
#$folderName =  "H:\01.01.2015-31.12.2015\AWP\Pay Data\30_12_2015\a8ce822b-33c2-4450-845a-5cdd3f54343f"
#$folderName = "\\RVN00-WD-TEST\WinDIP Extracts\MFDs (same extensions)\AWP\General\02_08_2017\c2340fb9-6804-4115-90ef-16ff66aba1e7"
#$folderName = "I:\MFDs (mixed extensions)\AWP\Contractual Documents\19_10_2015\0eec108d-9b37-451c-8ecb-ecb86bfeb947"
#$folderName = "C:\temp\WinDip Replacement\MFDs (mixed extensions)"
#$folderName = "H:\01.01.2010-31.12.2010\AWP\Contractual Documents\26_11_2010\a20bb557-b9f7-45b4-8885-4ed9a205e2f0"

if ( $folderName -eq $null ) {
    # H: maps to \\RVN00-WD-STORE\WinDIP_Archive$\WinDIP Extracts to avoid paths exceeding 260 chars
    Process-Folder -FolderFullPath "$Drive\\$global:topLevelFolderName\AWP" -logName $logName -runType DRY_RUN
} else {
    Process-Folder -FolderFullPath $folderName -logName $logName -runType DRY_RUN
}

Stop-Transcript
