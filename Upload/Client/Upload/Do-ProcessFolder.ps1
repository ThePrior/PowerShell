############################################################
#
# Main Entry Point
#
############################################################

$ErrorActionPreference = "Stop"

$stopAfterDocumentUploadCount = 9999999

$Global:documentUploadCount

$stopAfterCount = 9999999 # Note: This will include Xml files e.g. InfoPath files, as well as genuine WinDIP Xml metadata files. So count will not match number of document uploaded.

Function Processs-SubFolders( [string] $Path, [AWP_Upload_Processing]$runType ) {
        $message = "Processing folder {0}" -f $Path
        Log-Info $message

        $FolderCode = $null
        switch -WildCard ($global:topLevelFolderName) {

            "*2007*2007*" {  $FolderCode = "A"; Break }
            "*2008*2008*" {  $FolderCode = "B"; Break }
            "*2009*2009*" {  $FolderCode = "C"; Break }
            "*2010*2010*" {  $FolderCode = "D"; Break }
	
	        "*2011*2011*" {  $FolderCode = "E"; Break }
            "*2012*2012*" {  $FolderCode = "F"; Break }
            "*2013*2013*" {  $FolderCode = "G"; Break }
            "*2014*2014*" {  $FolderCode = "H"; Break }
	        "*2015*2015*" {  $FolderCode = "I"; Break }
            "*2016*2016*" {  $FolderCode = "J"; Break }
            "*2017*2017*" {  $FolderCode = "K"; Break }
            "*2018*2018*" {  $FolderCode = "L"; Break }	
            "*2019*2019*" {  $FolderCode = "M"; Break }
            "*2020*2021*" {  $FolderCode = "N"; Break }
	
            "*MFDs (mixed extensions)*" {  $FolderCode = "Y"; Break }
            "*MFDs (same extensions)*" {  $FolderCode = "Z"; Break }	
	
            Default {
                throw "Unrecognised top level folder name '$global:topLevelFolderName'"
            }
        }

        $Global:documentUploadCount = 0

        $currentCategoryFolder = $null
        $processedCount = 0


        Get-ChildItem -Path $FolderFullPath -Recurse -Include *.xml | ForEach-Object {

            if ( $_.Directory.Parent.Parent.Name -ne $currentCategoryFolder ) {
                $currentCategoryFolder = $_.Directory.Parent.Parent.Name
                #$message = "Processing new category: {0}" -f $currentCategoryFolder
                #Log-Info $message
            }

            $processedCount++
            #$message = "Processing file number {0}. '{1}' in {2}" -f $processedCount, $_.Name, $_.Directory.FullName 
            $message = "Processing Xml file number {0}: '{1}' (Note: includes InfoPath xml files so inaccurate as count of records processed!)" -f $processedCount, $_.Name 
            WriteLog $message

            Process-XmlFile $_.Name $_.Directory.FullName $runType -FolderCode $FolderCode

            $message = "Stop after {0}. Uploaded document count {1}" -f $stopAfterCount, $Global:documentUploadCount
            WriteLog $message

            if ($processedCount -ge $stopAfterCount) {
                $msg = "Processing terminated since stop after count is set to {0}" -f $stopAfterCount
                throw $msg
            }

            if ($Global:documentUploadCount -ge $stopAfterDocumentUploadCount) {
                $msg = "Processing terminated since documents uploaded ({0}) has reached or exceeded {1} " -f $Global:documentUploadCount, $stopAfterDocumentUploadCount
                throw $msg
            }
        }

}

Function Process-Folder {
    param
    (
        [string]
        [Parameter(Mandatory=$true)]
        $FolderFullPath,
        [string]
        [Parameter(Mandatory=$true)]
        $logName,
        [AWP_Upload_Processing]
        [Parameter(Mandatory=$true)]
        $runType
    )

    $runType = [AWP_Upload_Processing]::LIVE_UPLOAD

    Write-Host "*****************************************************************" -ForegroundColor Red
    Write-Host "*" -ForegroundColor Red
    Write-Host "* $runType ----- THIS IS NOT A DRILL" -ForegroundColor Red
    Write-Host "*" -ForegroundColor Red
    Write-Host "* $runType ----- To avoid 3 versions of files per upload Make sure to TURN OFF file versions in " -ForegroundColor Red
    Write-Host "* current staff & archived staff document libraries" -ForegroundColor Red
    Write-Host "*" -ForegroundColor Red
    Write-Host "*****************************************************************" -ForegroundColor Red


    $title    = "$runType - ACTION REQUIRED"
    $question = 'Make sure to TURN OFF file versions in current staff & archived staff document libraries before runing full migration upload. Are you sure you want to proceed?'

    $choices = New-Object Collections.ObjectModel.Collection[Management.Automation.Host.ChoiceDescription]
    $choices.Add((New-Object Management.Automation.Host.ChoiceDescription -ArgumentList '&Yes'))
    $choices.Add((New-Object Management.Automation.Host.ChoiceDescription -ArgumentList '&No'))

    $decision = $Host.UI.PromptForChoice($title, $question, $choices, 1)
    if ($decision -eq 0) {
    } else {
        exit
    }
	
	# Logging
    StartLog -logName $logName
	#$script:logLevel = [AWP_LogLevel]::LEVEL_INFO_AND_ABOVE
    $script:logLevel = [AWP_LogLevel]::LEVEL_ALL

    WriteLog "Process-Folder '$FolderFullPath' `n------`n"
    WriteLog "Run Type: $runType"
    WriteLog "Start Time: $(get-date)"

    try {

        $currentFolderBeingProcessed = $null
        $previousFolderBeingProcessed = $null

        Processs-SubFolders -Path $FolderFullPath -runType $runType

    } catch {
			# These are fatal exceptions
			HandleException 
            Save-ReportAs-CSV -CSV_FileName $global:topLevelFolderName 
            WriteLog "End Time: $(get-date)"
			SaveLog
			exit
	}

    Save-ReportAs-CSV -CSV_FileName $global:topLevelFolderName     

    Clear-UniqueFileNameGenerator

    WriteLog "End Time: $(get-date)"
    SaveLog
}