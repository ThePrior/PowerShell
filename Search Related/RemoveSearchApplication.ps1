#See: https://social.technet.microsoft.com/wiki/contents/articles/48051.sharepoint-2013-how-to-completely-remove-search-service-application.aspx

#Get-SPEnterpriseSearchServiceApplication 
#$ssa=Get-SPEnterpriseSearchServiceApplication
#$ssai1=Get-SPEnterpriseSearchComponent -SearchTopology 34dd50d5-29cb-4853-9238-09025740a3b5 -SearchApplication $ssa -Identity 4de2be2c-93e4-4994-87f9-e397f69e2220
#$ssai1


 #$ssi = Get-SPEnterpriseSearchServiceInstance
 #$ssi.Components   # Record the Index Location from here!

 #Get-SPServiceApplication | ?{$_.name -like "*Search*"}

 #$spapp = Get-SPServiceApplication -identity a887bddd-e80f-46c2-8ff0-b2ec70fda55e
 
 Write-Host "NOTE: Deleting the search application can take a while."
 #Remove-SPServiceApplication $spapp -RemoveData

 #Get-SPServiceApplicationProxy | sort-object TypeName | ft TypeName,ID -auto

 #Remove-SPServiceApplicationProxy 294ee0fc-21fd-4573-9801-5f2d5e77cbfb

 #Get-SPServiceApplicationPool | ft Name, ID -auto

 #$SPAppPool = Get-SPServiceApplicationPool "SharePoint Search Application Pool"
 #Remove-SPServiceApplicationPool $SPAppPool
 
 Write-Host "Remember to Delete the contents of the index locations you identified in the first step."