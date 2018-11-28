$ssa = Get-SPEnterpriseSearchServiceApplication

$active = Get-SPEnterpriseSearchTopology -SearchApplication $ssa -Active
$indexers = Get-SPEnterpriseSearchComponent -SearchTopology $active | ? {$_.Name -like "*IndexComponent*"}
$indexers | Select-Object -Property RootDirectory

#Get-SPEnterpriseSearchServiceApplication | ? { Get-SPEnterpriseSearchTopology -SearchApplication $_ | ? { Get-SPEnterpriseSearchComponent -SearchTopology $_ } }

#Get-SPEnterpriseSearchTopology -SearchApplication $ssa