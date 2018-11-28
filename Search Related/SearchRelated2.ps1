
$essi = Get-SPEnterpriseSearchServiceInstance
$cc = $essi.Components | ? { $_.GetType().Name -eq 'CrawlComponent' }
$cc.IndexLocation

#$ssa = Get-SPEnterpriseSearchServiceApplication


#$active = Get-SPEnterpriseSearchTopology -SearchApplication $ssa -Active
#Get-SPEnterpriseSearchComponent -SearchTopology $active