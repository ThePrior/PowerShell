Add-PSSnapin *sharepoint*


$farm = [Microsoft.SharePoint.Administration.SPFarm]::Local


$webServiceCollection = new-object Microsoft.SharePoint.Administration.SPWebServiceCollection($farm)


foreach ($service in $webServiceCollection)


{ foreach ($webApp in $service.WebApplications)


{ $firstWebApp = $webApp


#Get the context


$context = $firstWebApp.GetResponseUri([Microsoft.SharePoint.Administration.SPUrlZone]::Default)


Write-Host "Web Application Context:" $context.AbsoluteUri


#Call the token generator function


$token = [Microsoft.SharePoint.SPSecurityContext]::SecurityTokenForContext($context)


Write-Host "Token:" $token.InternalTokenReference


Write-Host "**************************" } }
