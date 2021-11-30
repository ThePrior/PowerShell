$resultsArrayList = [System.Collections.ArrayList]@()

$duplicateDectionHasTable = @{}

# Aim is to have ONLY one row in the CSV file for each file processed (or per error). This way can compare CSV row count with Civica extraction report figures.
Function Add-ReportEntry ( [AWP_Upload_Report_Type]$Type, [string]$FileName, $FileSizeKB, [string]$DirectoryFullPath, $Info, [string]$Details, [string]$FreeText, [boolean]$IsArchived ) {

    $existingEntry = $duplicateDectionHasTable["$DirectoryFullPath\$FileName"]
    if ($existingEntry -eq $null) {
        $duplicateDectionHasTable["$DirectoryFullPath\$FileName"] = $Type.ToString()
    } elseif ( $existingEntry -ne "INFO_ONLY" ) {
        if ( $Type.ToString() -ne "ERROR" ) {
            $msg = "$DirectoryFullPath\$FileName already reported as Type '{0}'"  -f $existingEntry
            throw $msg 
        }
    }

    $ReportEntry = New-Object PSObject

    $ReportEntry | Add-Member -MemberType NoteProperty -name "Type" -value $Type
    $ReportEntry | Add-Member -MemberType NoteProperty -name "Info" -value $Info
    $ReportEntry | Add-Member -MemberType NoteProperty -name "Details" -value $Details
    $ReportEntry | Add-Member -MemberType NoteProperty -name "FreeText" -value $FreeText
    $ReportEntry | Add-Member -MemberType NoteProperty -name "FileName" -value $FileName
    $ReportEntry | Add-Member -MemberType NoteProperty -name "FileSizeKB" -value $fileSizeKB
    $ReportEntry | Add-Member -MemberType NoteProperty -name "Folder" -value $DirectoryFullPath
    $ReportEntry | Add-Member -MemberType NoteProperty -name "IsArchived" -value $IsArchived
                
    $retval = $resultsArrayList.Add($ReportEntry)


    if ( [string]::IsNullOrEmpty($FreeText)  ) {
        $MoreDetails = $Details
    } else {
        $MoreDetails = "$Details, $FreeText"
    }

    if ( $info ) {
        $msg = "$Type, $Info, $MoreDetails, $FileName, $DirectoryFullPath, $IsArchived"
    } else {
        $msg = "$Type, $FileName, $DirectoryFullPath, $IsArchived"
    }

    Log-Verbose $msg
}

Function Save-ReportAs-CSV ( [string] $CSV_FileName ) {

    #Export report data to CSV
    $timeStamp = $(get-date).ToString('yyyy-MM-ddTHH-mm-ss')

    New-Item -ItemType Directory -Force -Path ".\Reports" | Out-Null

    $ReportFileName = ".\Reports\$CSV_FileName-$timeStamp.csv"
    $resultsArrayList | Export-Csv $ReportFileName –NoType

    Log-Warn "Duplicate file hash table has been cleared"
    $duplicateDectionHasTable = @{}
}