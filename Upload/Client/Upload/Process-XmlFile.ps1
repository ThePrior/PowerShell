Import-Module SharePointPnPPowerShell2016 -MinimumVersion 3.29.2101.0 -Force -ErrorAction Ignore

$ErrorActionPreference = "Stop"

# Configuration & static variables
$currentSiteWebUrl = "http://uatspace.awp.nhs.uk/sites/hrdocs/"
$archiveSiteWebUrl = "http://uatspace.awp.nhs.uk/sites/hrdocsarchive/"

$currentStaffListName = "CurrentStaff"
$archivedStaffListName = "Archived Staff"

$XmlDoBDateFormat = 'dd/MM/yyyy HH:mm:ss' # But sadly some DoBs are dd/MM/yy
$Xml_Filed_at_date_Format = 'dd/MM/yyyy HH:mm:ss'

# See: https://powershellexplained.com/2017-07-31-Powershell-regex-regular-expression/   NOTE - match seems to match anywhere in a line?
$NINO_RegEx = '^.*((?!BG)(?!GB)(?!NK)(?!KN)(?!TN)(?!NT)(?!ZZ)(?:[A-CEGHJ-PR-TW-Z][A-CEGHJ-NPR-TW-Z])(?:\s*\d\s*){6}([A-D]|\s)).*$'
$illegalCharacterArray = '#','%','&','~' # Others are illegal in Windows

Connect-PnPOnline $currentSiteWebUrl -CurrentCredentials


<# TO READ ALL LIST ITEMS: ADAPT THIS 
# Retrieves all list items from the Tasks list in pages of 1000 items and breaks permission inheritance on each item
Get-PnPListItem -List Tasks -PageSize 1000 -ScriptBlock { Param($items) $items.Context.ExecuteQuery() } | ForEach-Object { $_.BreakRoleInheritance($true, $true) }
#>



Function Process-XmlFile ( [string] $XmlFileName, [string] $DirectoryFullPath, [AWP_Upload_Processing]$runType, [string]$FolderCode ) {

    $XmlFullPathName = $DirectoryFullPath + "\" + $XmlFileName

	$IsMFD = $false
	if ( $DirectoryFullPath -like '*\MFDs*') {
		$IsMFD = $true
		
		#Log-Info "Support for MFDs. Basically anywhere $FileName is used below, if MFD need to iterate over contents of folder instead. (But excluding the WinDIP Xml file of course)."
	}

    try {

        [xml]$xmlDocument = Get-Content -LiteralPath $XmlFullPathName

        if ( $IsMFD ) {
            $NumberOfFiles = $xmlDocument.Windip_Meta_Data.Windip_record_data.Page_Count # Page_count is not very useful as number of files for MFDs, since TIFF files can have multiple pages.
            $FileName = $XmlFileName
        } else {
            $FileName = $xmlDocument.Windip_Meta_Data.Windip_record_data.Filename
            $NumberOfFiles = 1
        }

        $Filed_at_date = $xmlDocument.Windip_Meta_Data.Windip_record_data.Filed_at_date

        $Category = $xmlDocument.Windip_Meta_Data.Windip_record_data.Information_Type

        $EmployeeNumber = $xmlDocument.Windip_Meta_Data.Document_Index_data.Index_1

        # NOTE: 2007 year stores First Name / Last Name in reverse order fields. Maybe other years as well.
        if ( $global:topLevelFolderName -like '*2007*' ) {
            $LastName = $xmlDocument.Windip_Meta_Data.Document_Index_data.Index_3
            $FirstName = $xmlDocument.Windip_Meta_Data.Document_Index_data.Index_2
        } else {
            $LastName = $xmlDocument.Windip_Meta_Data.Document_Index_data.Index_2
            $FirstName = $xmlDocument.Windip_Meta_Data.Document_Index_data.Index_3
        }

        $DoB = $xmlDocument.Windip_Meta_Data.Document_Index_data.Index_4
        $FreeText = $xmlDocument.Windip_Meta_Data.Document_Index_data.Index_5

        # Only flag as invalid Xml file if both are missing.

        if ( [string]::IsNullOrEmpty($EmployeeNumber) ) {
    
            $isInvalidXmlFile = $false

            if ( $XmlFileName -like "*_metafile.xml" ) {
                # If the file being processed is an Xml metafile then this is an error 
                $isInvalidXmlFile = $true            
            } elseif ( $(Test-Path "$DirectoryFullPath\*_metafile.xml") -eq $false ) {
                # File is NOT an Xml metafile (it most likely is an InfoPath Xml file) so it is an error since the folder does NOT ALSO contain an Xml metafile.
                $isInvalidXmlFile = $true
            }


            if ( $isInvalidXmlFile ) {
                # Note: We must add (at least) two records, one for the Xml file and one for the actual document(s). 
                # The report should contain one record per Xml file processed and one record for each other document. (Except INFO records).
                Add-ReportEntry -Type INVALID_XML_FILE -FileName $XmlFileName -DirectoryFullPath $DirectoryFullPath -Info "Employee number is missing at Index_1 in xml file" -FreeText $FreeText -LastName $LastName -FirstName $FirstName -DoB $DoB
                    
                Get-ChildItem -Path $DirectoryFullPath -Name -Exclude $XmlFileName | foreach {
                        Add-ReportEntry -Type NO_VALID_METADATA -FileName $_ -DirectoryFullPath $DirectoryFullPath -Info "Employee number is missing at Index_1 in corresponding xml file" -FreeText $FreeText -LastName $LastName -FirstName $FirstName -DoB $DoB
                }
            }

        } else {
            # add a report entry for the Xml file
            Add-ReportEntry -Type PROCESSED_XML_FILE -FileName $XmlFileName -DirectoryFullPath $DirectoryFullPath 


            $FileNameArray = @()
            if ( $IsMFD ) {
                Get-ChildItem -Path $DirectoryFullPath -Name -Exclude $XmlFileName | foreach {
                        $FileNameArray += $_
                }                    
            } else {
                $FileNameArray += $FileName
            }

            if ($FileNameArray.Count -gt $NumberOfFiles){
                # NOTE: In the case of MFD files, the number of files is a maximum (since pages in TIFF files count one each).
                $msg = "Too many files in folder $DirectoryFullPath. Expected at most {0}, Found {1} (excluding Xml metadata file)" -f $NumberOfFiles, $FileNameArray.Count
                throw $msg
            }


            $NINO = [SharePointLookups]::GetNINOFromEmployeeNumber( $EmployeeNumber )

            # Some old Xml files have invalid 4 digit Employee Numbers, so we if no match found check for a NINO in the FreeText field or the filename.
            if ( [string]::IsNullOrEmpty($NINO) ) {

                $Matches = $null
                $NINOFoundInFreeText = $FreeText -match $NINO_RegEx
                if ($NINOFoundInFreeText) {
                    $NINO = $Matches[1]
                    Log-Info "Found NINO $NINO in Free text field $FreeText"
                } else {
                    $Matches = $null
                    $NINOFoundInFileName = $XmlFileName -match $NINO_RegEx
                    if ($NINOFoundInFileName) {
                        $NINO = $Matches[1]
                        Log-Info "Found NINO $NINO in Xml file name $XmlFileName"
                    }
                } 

                if ( $NINOFoundInFreeText -eq $false -and $NINOFoundInFileName -eq $false ) {
                    $msg = "Invalid employee number and no NINO found in either Free Text '{0}' or Xml file name {1}" -f $FreeText, $XmlFileName
                    Log-Info $msg
                }
            }
                
            if ( [string]::IsNullOrEmpty($NINO) ) {
                $msg = "NINO for Employee Number {0} - Not found in All Employees list." -f $EmployeeNumber
                foreach( $FileName in $FileNameArray ) {
                    Add-ReportEntry -Type ERROR -FileName $FileName -DirectoryFullPath $DirectoryFullPath -Info "No matching employee number found in HR Docs" -Details $msg -FreeText $FreeText -LastName $LastName -FirstName $FirstName -DoB $DoB
                }
            } else {

                $matchingAllEmployeeNumbersListItem = [SharePointLookups]::GetAllEmployeeNumbersFromNINO( $NINO )

                if ( $matchingAllEmployeeNumbersListItem -ne $null ) {
                    $DocSetName = $matchingAllEmployeeNumbersListItem["DocumentSetFolderName"]
                    $IsArchived = $matchingAllEmployeeNumbersListItem["IsArchived"]
                    $TerminationDate = $matchingAllEmployeeNumbersListItem["AWP_HrDocs_TerminationDate"]
                }

                if ( [string]::IsNullOrEmpty($DocSetName) ) {

                    $msg = "NI Number {0} - Matching Document Set Folder Name not found in AllEmployeeNumbers list." -f $NINO
                    foreach( $FileName in $FileNameArray ) {
                        Add-ReportEntry -Type ERROR -FileName $FileName -DirectoryFullPath $DirectoryFullPath -Info "No matching employee record found in HR Docs" -Details $msg -FreeText $FreeText -LastName $LastName -FirstName $FirstName -DoB $DoB
                    }

                } else {

                    $DoUpload = $false
                
                    if ( $IsArchived) {

                        $timeSpan = New-TimeSpan -Start $TerminationDate -End $(get-date)
                        if ( $timeSpan.Days -gt 365 * 7 + 2 ) { # good enough hopefully

                            # User bucket over-due for deletion - IGNORE
                            $msg = "NINO {0} - Termination date {1}" -f $NINO, $TerminationDate
                            foreach( $FileName in $FileNameArray ) {
                                Add-ReportEntry -Type IGNORED -XmlFileName $XmlFileName -FileName $FileName -DirectoryFullPath $DirectoryFullPath -Info "Termination date more than 7 years ago" -Details $msg -FreeText $FreeText -LastName $LastName -FirstName $FirstName -DoB $DoB
                            }

                        } else {

                            if ( $timeSpan.Days -le 365 * 7 + 2 -and $timeSpan.Days -ge 365 * 7 - 92 ) {

                                # User bucket due for deletion in the next three months - add these bad boys to the report but do the upload.
                                $msg = "NINO {0} - Termination date {1}" -f $NINO, $TerminationDate
                                foreach( $FileName in $FileNameArray ) {
                                    Add-ReportEntry -Type INFO_ONLY -XmlFileName $XmlFileName -FileName $FileName -DirectoryFullPath $DirectoryFullPath -Info "Deletion due in next three months" -Details $msg -FreeText $FreeText -LastName $LastName -FirstName $FirstName -DoB $DoB
                                }
                            }

                            $DoUpload = $true
                            $SharePointFolderName = $archivedStaffListName + "/" + $DocSetName
                            Connect-PnPOnline $archiveSiteWebUrl -CurrentCredentials
                        }
                    } else {
                        $DoUpload = $true
                        $SharePointFolderName = $currentStaffListName + "/" + $DocSetName
                    }

                    # Xml Format is e.g. 22/03/1964 00:00:00. BUT turns out some DoBs are filed as DD/MM/YY.
                    # We can ignore the DoB, since documents will just inherit from the owning bucket.
                    #$AWP_HrDocs_DOB = [datetime]::parseexact($DoB, $XmlDoBDateFormat, $null)
 
                    # Filed_at_date is usually in format e.g. 11/05/2017 12:09:30, but some are just dd/MM/yyyy with no time elements. Seems odd for a system generated field, but hey.
                    $AWP_HrDocs_Filed_at_date = [datetime]::parse($Filed_at_date)
               
                    if ($DoUpload) {

                        $Category = Map-Category $Category

                        foreach( $FileName in $FileNameArray ) {
                            Upload-Document $FileName $DirectoryFullPath $SharePointFolderName $NINO $EmployeeNumber $LastName $FirstName $AWP_HrDocs_Filed_at_date $Category $FreeText $DoB $runType $IsArchived $FolderCode
                        }

                        Update-Categories $Category
                    } 
            
                }
            }
        }

    } catch {
        Add-ReportEntry -Type ERROR -FileName $FileName -DirectoryFullPath $DirectoryFullPath -Info "Unexpected error" -Details $PSItem.Exception.Message
        HandleException 
	} finally {
        if ( $IsArchived ) {
            # Restore the default connection for access to All Employees list etc.
            Connect-PnPOnline $currentSiteWebUrl -CurrentCredentials
        } 
    }

}

<#
    NOTE: To avoid issues parsing the DoB (and possible typos) just inherit this from the containing bucket. 
          We would like to keep the lastname & first name in case of a name change, but they are over-written by the inerited properties as well. Too bad.
#>
Function Upload-Document ( $FileName, $DirectoryFullPath, $SharePointFolderName, $NINO, $EmployeeNumber, $LastName, $FirstName, [DateTime]$AWP_HrDocs_Filed_at_date, $Category, 
        [string]$FreeText, [string]$DoB, 
        [AWP_Upload_Processing]$runType, [boolean]$IsArchived,
        [string]$FolderCode) {

    $SharePoint_WinDip_Filed_at_Date = SharePointDateTimeAsString $AWP_HrDocs_Filed_at_date $true
    $WindowsFullFileName = $DirectoryFullPath + "\" + $FileName
    $fileSizeKB = [math]::ceiling((Get-Item $WindowsFullFileName).length/1KB)

    switch ( $runType ) {

        DRY_RUN {
            Add-ReportEntry -Type DRY_RUN_UPLOADED -FileName $FileName -DirectoryFullPath $DirectoryFullPath -FileSizeKB $fileSizeKB -FreeText $FreeText -LastName $LastName -FirstName $FirstName -DoB $DoB -IsArchived $IsArchived
            $Global:documentUploadCount++
            break
        }
        LIVE_UPLOAD {

            $NewFileName = $FileName
            if ( $NewFileName.IndexOfAny($illegalCharacterArray) -ne -1 ) {
                $HasIllegalCharacters = $true
            }

            if ($HasIllegalCharacters ) {

                if ($NewFileName.IndexOf('&') -ne -1) {
                    $NewFileName = $NewFileName -replace ' & ', ' and '
                    $NewFileName = $NewFileName -replace '&', ' and '
                } 

                if ($NewFileName.IndexOf('%') -ne -1) {
                    $NewFileName = $NewFileName -replace ' % ', ' pc '
                    $NewFileName = $NewFileName -replace '%', 'pc'
                }

                if ( $NewFileName.IndexOf('#') -ne -1 ) {
                    $NewFileName = $NewFileName -replace '#', '-'
                }

                if ( $NewFileName.IndexOf('~') -ne -1 ) {
                    $NewFileName = $NewFileName -replace '~', '-'
                }
            }

            $NewFileName = [UniqueFileNameGenerator]::GetUniqueFileName( $SharePointFolderName, $NewFileName, $FolderCode )

            $FileSiteRelativeURL = "$SharePointFolderName/$NewFileName" 

            $FileExists = Get-PnPFile -Url $FileSiteRelativeURL -ErrorAction SilentlyContinue

            if ( $FileExists ) {
                Add-ReportEntry -Type ALREADY_UPLOADED -FileName $FileName -DirectoryFullPath $DirectoryFullPath  -FileSizeKB $fileSizeKB -FreeText $FreeText -LastName $LastName -FirstName $FirstName -DoB $DoB -IsArchived $IsArchived
            } else {
                
                if ( $HasIllegalCharacters ) {
                    Add-PnPFile -Path $WindowsFullFileName -NewFileName $NewFileName -Folder $SharePointFolderName -ContentType "AWP HR Document" -Values @{
                                                #"AWP_HrDocs_NINO" = $NINO; #Inherited from Document Set
                                                "AWP_HrDocs_EmployeeNumber" = $EmployeeNumber;
                                                #"AWP_HrDocs_LastName" = $LastName; #Inherited from Document Set
                                                #"AWP_HrDocs_FirstName" = $FirstName; #Inherited from Document Set
                                                #"AWP_HrDocs_DOB" = $SharePointDoB; #Inherited from Document Set
                                                "AWP_HrDocs_Filed_at_date" = $SharePoint_WinDip_Filed_at_Date;
                                                "AWP_HrDocs_Category" = $Category;
                                                "AWP_HrDocs_FreeText" = $FreeText;
                                                }  -ErrorAction Stop | Out-Null
                } else {
                    Add-PnPFile -Path $WindowsFullFileName -Folder $SharePointFolderName -ContentType "AWP HR Document" -Values @{
                                                #"AWP_HrDocs_NINO" = $NINO; #Inherited from Document Set
                                                "AWP_HrDocs_EmployeeNumber" = $EmployeeNumber;
                                                #"AWP_HrDocs_LastName" = $LastName; #Inherited from Document Set
                                                #"AWP_HrDocs_FirstName" = $FirstName; #Inherited from Document Set
                                                #"AWP_HrDocs_DOB" = $SharePointDoB; #Inherited from Document Set
                                                "AWP_HrDocs_Filed_at_date" = $SharePoint_WinDip_Filed_at_Date;
                                                "AWP_HrDocs_Category" = $Category;
                                                "AWP_HrDocs_FreeText" = $FreeText;
                                                }  -ErrorAction Stop | Out-Null
                }


                Add-ReportEntry -Type UPLOADED -FileName $FileName -DirectoryFullPath $DirectoryFullPath  -FileSizeKB $fileSizeKB -FreeText $FreeText -LastName $LastName -FirstName $FirstName -DoB $DoB -IsArchived $IsArchived
                $Global:documentUploadCount++
            }
            break
        } 
    }
}

# Avoid the nightmare of PowerShell 4 return semantics - see https://stackoverflow.com/questions/10286164/function-return-value-in-powershell/42743143#42743143

class SharePointLookups {
    static [string] $AllEmployeesList = "All Employees" # DO NOT RENAME LIST IN HR DOCS!
    static [string] $AllEmployeesQueryTemplate = "<View><ViewFields><FieldRef Name='AWP_HrDocs_NINO'/></ViewFields><Query><Where><Eq><FieldRef Name='AWP_HrDocs_EmployeeNumber'/><Value Type='Text'>{0}</Value></Eq></Where></Query></View>"

    static [string] $AllEmployeeNumbersList = "All Employee Numbers" # DO NOT RENAME LIST IN HR DOCS!
    static [string] $AllEmployeeNumbersQueryTemplate = "<View><ViewFields><FieldRef Name='DocumentSetFolderName'/><FieldRef Name='IsArchived'/><FieldRef Name='AWP_HrDocs_TerminationDate'/></ViewFields><Query><Where><Eq><FieldRef Name='Title'/><Value Type='Text'>{0}</Value></Eq></Where></Query></View>"

    static [object] GetAllEmployeeNumbersFromNINO( [string]$NINO) {

        $queryString = [SharePointLookups]::AllEmployeeNumbersQueryTemplate -f $NINO
        $listName = [SharePointLookups]::AllEmployeeNumbersList
        $items = Get-PnPListItem -List $listName -Query $queryString
        

        # Only ever one entry since NINO is unique in the AllEmployeeNumbers list
        if ( $items.Count -gt 1 ) {
            throw "More than one matching item found in All Employee Numbers list for NINO $NINO"
        }

        $matchingItem = $null
        foreach ( $item in $items ) {
            $matchingItem = $item
        }
            
        return $matchingItem
    }

    static [string] GetNINOFromEmployeeNumber( [string]$EmployeeNumber ) {

        $queryString = [SharePointLookups]::AllEmployeesQueryTemplate -f $EmployeeNumber
        $listName = [SharePointLookups]::AllEmployeesList

        $items = Get-PnPListItem -List $listName -Query $queryString

        # Only ever one entry since Employee Number is unique in the AllEmployees list
        $NINO = $null
        foreach ( $employee in $items ) {
            $NINO = $employee["AWP_HrDocs_NINO"]
        } 
    
        return $NINO  
    }

    static [string] GetDocSetName( [string]$EmployeeNumber ) {

        $NINO = [SharePointLookups]::GetNINOFromEmployeeNumber( $EmployeeNumber )
        if ( $NINO -eq $null ) {
            $msg = "No National Insurance number found for Employee Number '{0}' in 'the 'All Employees' list" -f $EmployeeNumber
            Log-Error $msg
            return $null
        }

        $FolderName = Get-DocSetNameFromNINO $NINO
        return $FolderName
        
    }

    static [string] GetDocSetNameFromNINO( [string]$NINO ) {

        $queryString = [SharePointLookups]::AllEmployeeNumbersQueryTemplate -f $NINO
        $listName = [SharePointLookups]::AllEmployeeNumbersList
        $items = Get-PnPListItem -List $listName -Query $queryString

        # Only ever one entry since NINO is unique in the AllEmployeeNumbers list
        $FolderName = $null
        foreach ( $item in $items ) {
            $FolderName = $item["DocumentSetFolderName"]
        }    

        return $FolderName       
    }
}

# For each folder location in SharePoint we need to ensure FileNames are unique.
# Do this by appending the FolderCode: A, B, C based on the WinDip toplevel folder name (this ensures uniqueness across parallel uploads) and
# a numeric count incremented for each matching filename in the folder.
# Example folders process - H:\01.01.2016-31.12.2016\AWP\Contractual Documents\
#     H:\01.01.2016-31.12.2016\AWP\Contractual Documents\20_09_2016\2dd925a5-404e-4f1f-92b2-22688b8861e4
#     H:\01.01.2016-31.12.2016\AWP\Contractual Documents\20_10_2016\45e5245e-06e6-468d-a9a9-0a9c5daccebf
class UniqueFileNameGenerator {
    
    static [object] $FolderFileNameHashTable = @{}

    static [string] GetUniqueFileName( [string]$SharePointFolderName, [string]$FileName, [string]$FolderCode) {

        
        $newFileName = $null

        $count = [UniqueFileNameGenerator]::FolderFileNameHashTable["$SharePointFolderName\$FileName"]
        if ($count -eq $null) {
            $count = 1
        } else {
            $count++
        }

        [UniqueFileNameGenerator]::FolderFileNameHashTable["$SharePointFolderName\$FileName"] = $count
                        
        if ($count -lt 10 ) {
            $newFileName = "{0} - {1}{2:D1}" -f $FileName, $FolderCode, $count
        } else {
            $newFileName = "{0} - {1}{2:D2}" -f $FileName, $FolderCode, $count
        }

        if ($count -ge 100 ) {
            $msg = "Over 99 documents in the same user bucket with the same file name is not supported. SharePointFolderName '{0}'" -f $SharePointFolderName
        }

        return $newFileName

    }

    static [void] ClearUniqueFileNameGenerator( ) {
        $duplicateCount = 0
        $duplicateTotalCount = 0
        foreach ( $value in [UniqueFileNameGenerator]::FolderFileNameHashTable.Values ) {
            if ($value -gt 1 ){
                $duplicateCount++
                $duplicateTotalCount = $duplicateTotalCount + $value - 1
            }
        }

        $msg = "Unique duplicate file names found = {0}. Total number of duplicate file names detected = {1}" -f $duplicateCount, $duplicateTotalCount
        Log-Info $msg

        [UniqueFileNameGenerator]::FolderFileNameHashTable = @{}
        Log-Warn "Unique File Name Generator file hash table has been cleared"
    }

}

Function Clear-UniqueFileNameGenerator (  ) {
    [UniqueFileNameGenerator]::ClearUniqueFileNameGenerator()
}