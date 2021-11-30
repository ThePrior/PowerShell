#$categories = 'Contractual Documents','Disciplinaries','General','Grievances','Non-AWP employed staff','Pay Data','Pension','Sickness' # NOTE: There are more now. see categories.json file

#$categories | ConvertTo-Json | Set-Content -Path .\Categories.json

$categoriesAsJson = Get-Content -Path .\Categories.json -Raw

$categories = ConvertFrom-Json -InputObject $categoriesAsJson

$script:categoriesHashTable = @{}

foreach ($category in $categories) {
    $script:categoriesHashTable.Add($category, $true)
}

Function Update-Categories ( [string]$category ) {

    if ( $script:categoriesHashTable.Contains($category) -eq $false ) {
        
        $script:categoriesHashTable.Add($category, $true)

        $script:categoriesHashTable.Keys | sort | ConvertTo-Json | Set-Content -Path .\Categories.json
    }
}

Function Map-Category ( [string]$category ) {


    if ( $category -eq "Archive" ) {
        return "Archived Files"
    }
    
    if ( $script:categoriesHashTable.Contains($category) -eq $true ) {
        return $category
    }

    $msg = "Unknown category found: '{0}'. Ask HR to advise how to handle this category." -f $category
    throw $msg
}

#Update-Categories "Test1234"




