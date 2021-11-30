cls

cd $PSScriptRoot

$global:scriptName = $MyInvocation.MyCommand.Name
#$global:topLevelFolderName = "01.01.2017-31.12.2017"
#$global:topLevelFolderName = "01.01.2016-31.12.2016"
#$global:topLevelFolderName = "01.01.2015-31.12.2015"
#$global:topLevelFolderName = "01.01.2014-31.01.2014"
#$global:topLevelFolderName = "01.01.2013-31.12.2013"
#$global:topLevelFolderName = "01.01.2012-31.12.2012"
$global:topLevelFolderName = "01.01.2011-31.01.2011"



$logName = "$global:scriptName"

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

if ( $folderName -eq $null ) {
    # H: maps to \\RVN00-WD-STORE\WinDIP_Archive$\WinDIP Extracts to avoid paths exceeding 260 chars
    Process-Folder -FolderFullPath "H:\\$global:topLevelFolderName\AWP" -logName $logName -runType DRY_RUN
} else {
    Process-Folder -FolderFullPath $folderName -logName $logName -runType DRY_RUN
}

Stop-Transcript
