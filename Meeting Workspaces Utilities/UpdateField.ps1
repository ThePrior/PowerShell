Add-PsSnapin Microsoft.SharePoint.PowerShell

$site = Get-SPsite http://uatmeetingportal.awp.nhs.uk/sites/Meetings
$listname = "New Task" #ENTER THE NAME OF THE LIST THAT WILL BE UPDATED
$fieldstoupdate = @("Reviewer") #ENTER THE LIST OF FIELDS TO BE UPDATED

#ENUMERATE ALL WEBS IN SITE COLLECTION  
foreach ($web in $site.AllWebs) {
    
    #CHECK IF WEB CONTAINS LIST WE WANT TO UPDATE USING NEW METHOD TryGetList()
    $list=$web.Lists.TryGetList($listName)
    if($list -ne $null) {
        Write-host -f black "List"$list.Title "on"$web.Name "at URL"$web.Url
        
        #GET ARRAY OF FIELDS TO UPDATE
        foreach ($field in $fieldstoupdate) {
            
            $fieldname = $list.Fields["$field"]
            $fieldname.required = $true
            $fieldname.update()
            Write-Host -f green "Updated field"$fieldname
        }
    }
    else {
        Write-Host -f red $listName "does not exist in the subsite"$web.Name", skipping"
    } 
}
$web.Dispose()
$site.dispose()