#$db = Get-SPDatabase -Identity 550256eb-466a-4d82-a050-2c32bd1c3089 
#$db = Get-SPDatabase  -Identity 02a1d438-0842-4098-808f-d33fa1db54f4 #Content_Workspaces

$db = Get-SPDatabase
#$db | Format-Table -Property Name, Type, Server, Id

$db | Sort -Property Name | Select-Object -Property Name, Type, Server, NormalizedDataSource | Export-Csv -path U:\DBs.csv -NoTypeInformation