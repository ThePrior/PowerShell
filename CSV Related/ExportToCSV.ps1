# Get COM Object
$oExcel = New-Object -ComObject "Excel.Application"
# Should Excel be visible?
$oExcel.Visible = $true

$date = "2020-07-02"

$sExcelInputFolderxlsx="C:\temp\PhysicalHealth - With LDU and Site\Results\" + $date
$sCSVOutputFolder="C:\temp\PhysicalHealth - With LDU and Site\Analysis\InputCsvFiles\"

if(!(Test-Path $sCSVOutputFolder))
{
    mkdir $sCSVOutputFolder
}

get-item ($sExcelInputFolderxlsx+"\*.xlsx") | foreach  {
    $sOutputFile=[System.IO.Path]::Combine($sCSVOutputFolder,($_.Basename+"-"+$date+".csv"))
    # open excel file
    $oExcelDoc = $oExcel.Workbooks.Open($_.FullName)
    # Open 1st Worksheet
    $oWorksheet = $oExcelDoc.Worksheets.item(1)
    # Activate, show it
    $oWorksheet.Activate()	
    write-host "Save" $sOutputFile
    $oExcelDoc.SaveAs($sOutputFile,[Microsoft.Office.Interop.Excel.XlFileFormat]::xlCSVWindows)
    $oExcelDoc.Close($false)
    Start-Sleep 1
    # Cleanup COM
    [System.Runtime.InteropServices.Marshal]::ReleaseComObject($oWorksheet)|out-null
    $oWorksheet=$null
    Start-Sleep 1
    # Cleanup COM
    [System.Runtime.InteropServices.Marshal]::ReleaseComObject($oExcelDoc)|out-null
    $oExcelDoc=$null	
}
# Close Excel
$oExcel.Quit()
Start-Sleep 1
# Cleanup COM
[System.Runtime.InteropServices.Marshal]::ReleaseComObject($oExcel)|out-null
$oExcel=$null
[GC]::Collect()
[GC]::WaitForPendingFinalizers()