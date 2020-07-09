cls
$CSVInputFolder="C:\temp\PhysicalHealth - With LDU and Site\Analysis\InputCsvFiles\"
$CSVOutputFolder="C:\temp\PhysicalHealth - With LDU and Site\Analysis\OutputCsvFiles\"

$outputData = New-Object System.Collections.ArrayList

$user_LearningResource_LDU_HashTable = @{}

get-item ($CSVInputFolder+"\*.csv") | foreach  {
    
    $learningResource = $_.BaseName
    $learningResource = $learningResource -replace "-2020.*",""

    Import-Csv $_.FullName | ForEach-Object {

        #Need to remove nasty trailing special characters 
        $LDU = [String]($_.LDU)
        $LDU = $LDU -replace '[^ -~]', ''
        $LDU = $LDU.Trim()

        #Only output each user access once per learning resource and LDU
        $key = ($_.UserLogin) + "-" + $learningResource + "-" + $LDU
        if (!$user_LearningResource_LDU_HashTable.ContainsKey($key)){

            $user_LearningResource_LDU_HashTable.Add($key, $true)

            #Save the data
            $outputRow = [PSCustomObject]@{}


            $outputRow | Add-Member -MemberType NoteProperty -Name "UserLogin" -Value ($_.UserLogin)
            $outputRow | Add-Member -MemberType NoteProperty -Name "LogTime" -Value ($_.LogTime)
            $outputRow | Add-Member -MemberType NoteProperty -Name "LDU" -Value $LDU
            $outputRow | Add-Member -MemberType NoteProperty -Name "Site_Name" -Value ($_.Site_Name)
            $outputRow | Add-Member -MemberType NoteProperty -Name "Learning Resource" -Value $LearningResource

            $outputData.Add($outputRow) | Out-Null
        }


    }
}

$outputData | Export-Csv -Path ($CSVOutputFolder + "CollatedData.csv") -NoTypeInformation 

Write-Host ($outputData.Count, " rows saved to file : ", $CSVOutputFolder + "CollatedData.csv")