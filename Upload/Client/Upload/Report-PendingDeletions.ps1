
$script:PendingDeleteArrayList = [System.Collections.ArrayList]@()

Function Add-PendingDelete ( [AWP_Upload_Report_Type]$Type, [string]$XmlFileName, [string]$FileName, [string]$DirectoryFullPath, $Info, [string]$Details  ) {

    Log-Error "Not needed, since now using INFO_ONLY in CSV Report file to report these cases. Not implemented fully"
    exit
    $ReportEntry = New-Object PSObject

    $ReportEntry | Add-Member -MemberType NoteProperty -name "Type" -value $Type
    $ReportEntry | Add-Member -MemberType NoteProperty -name "FileName" -value $FileName
    $ReportEntry | Add-Member -MemberType NoteProperty -name "Folder" -value $DirectoryFullPath
    $ReportEntry | Add-Member -MemberType NoteProperty -name "NINO" -value $NINO
    $ReportEntry | Add-Member -MemberType NoteProperty -name "Employee Number" -value $EmployeeNumber
    $ReportEntry | Add-Member -MemberType NoteProperty -name "Termination Date" -value $TerminationDate
    $ReportEntry | Add-Member -MemberType NoteProperty -name "Details" -value "Termination date more than 7 years ago"

    Add-ReportEntry $ReportEntry
}

Function Save-PendingDeletes-As-CSV (  ) {

    #Export report data to CSV
    $timeStamp = $(get-date).ToString('yyyy-MM-ddTHH-mm-ss')

    New-Item -ItemType Directory -Force -Path ".\Reports" | Out-Null

    $ReportFileName = ".\Reports\Pending-Deletes-$timeStamp.csv"
    $script:pendingDeleteArrayList | Export-Csv $ReportFileName –NoType

}