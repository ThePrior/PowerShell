Function Get-SharePointDateTimeAsString ( [DateTime]$dateTime, [bool]$includeTime ) {
    if ($includeTime) {
        $SharePointDateTime = $dateTime.ToString('yyyy-MM-ddTHH:mm:ssZ') 
    } else {
        $SharePointDateTime = $dateTime.ToString('yyyy-MM-ddT00:00:00Z')         
    }
    $SharePointDateTime
}

