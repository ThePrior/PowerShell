Add-PsSnapin Microsoft.SharePoint.PowerShell

  #[void][System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms")|Out-Null 

   Function Show-MsgBox ($Text,$Title="",[Windows.Forms.MessageBoxButtons]$Button = "OK",[Windows.Forms.MessageBoxIcon]$Icon="Information"){
     [Windows.Forms.MessageBox]::Show("$Text", "$Title", [Windows.Forms.MessageBoxButtons]::$Button, $Icon) | ?{(!($_ -eq "OK"))}
   }


   if((Show-MsgBox -Title 'Confirm CleanUp' -Text 'Warning: this scripts deletes user groups and optionally sites. Are you sure you want to continue?'-Button YesNo -Icon Warning) -eq 'No'){
     Exit
   }
   
   
$CurrentDir = Resolve-Path .
$logfile=$CurrentDir.Path + "\DeleteGroupsAndSubsites.log"

Start-Transcript $logfile -Append
   $spWeb = Get-SPWeb "http://prdspace.awp.nhs.uk/sites/Meetings"
   $spGroups = $spWeb.SiteGroups

   Write-Host "This site has" $spGroups.Count "groups"
   ""
   $doNotDeleteGroupNames = ("Everyone", "Approvers",
     "awp readers",
     "ApprovedWorkspace Members","ApprovedWorkspace Owners","ApprovedWorkspace Visitors ",
     "Board Members", "Board Owners", "Board Visitors",
     "Chief Executive Members", "Chief Executive Owners", "Chief Executive Visitors",
     "Designers", 
     "Excel Services Viewers",
     "Hierarchy Managers",
     "Hierarchy Managers2",
     "Quality & Standards Members","Quality & Standards Owners","Quality & Standards Visitors",
     "Quick Deploy Users",
     "Restricted Readers",
     "Style Resource Readers",
     "Swindon LDU Members","Swindon LDU Owners","Swindon LDU Readers",
     "Translation Managers",
     "Trustwide Members","Trustwide Owners","Trustwide Visitors"
   )

   $groups = $spGroups | ? {$_.Name -notin $doNotDeleteGroupNames}
   Write-Host "Found" $groups.Count "groups for deletion:"

   ForEach($group in $groups) {
     #Write-Host $group.Name
     Write-Host "Deleting" $group.Name "..."
     $spGroups.Remove($group.Name) 
   }

   $spWeb.Dispose()


   $spWeb.Dispose()

   ###################################################################
   #
   # Delete subsites of given site
   #
   ###################################################################


   #Custom Function to Delete subsite recursively
   function Remove-SPWebRecursively([Microsoft.SharePoint.SPWeb] $web, [bool]$IncludeStartWeb)
   {
     $ChildWebsColl = $web.webs
    
     foreach($ChildWeb in $ChildWebsColl)
     {
       #Call the function recursively
       Remove-SPWebRecursively $ChildWeb $true
       $ChildWeb.Dispose()
     }
    
     #Remove the web  
     if ($IncludeStartWeb)
     {
       Write-host "Removing Web $($web.Url)..."
       Remove-SPWeb $web -Confirm:$true
     }
   }


   #Site URL
   $ParentWebURL="http://prdspace.awp.nhs.uk/sites/Meetings/LDU_Swindon"
   $ParentWeb = Get-SPWeb $ParentWebURL

   #Call the function to remove subsite
   Remove-SPWebRecursively $ParentWeb $false

   $ParentWeb.Dispose()

   $ParentWebURL="http://prdspace.awp.nhs.uk/sites/Meetings/Board"
   $ParentWeb = Get-SPWeb $ParentWebURL

   #Call the function to remove subsite
   Remove-SPWebRecursively $ParentWeb $false

   $ParentWeb.Dispose()

   $ParentWebURL="http://prdspace.awp.nhs.uk/sites/Meetings/Trust"
   $ParentWeb = Get-SPWeb $ParentWebURL

   #Call the function to remove subsite
   Remove-SPWebRecursively $ParentWeb $false

   $ParentWeb.Dispose()

Stop-Transcript 
Remove-PsSnapin Microsoft.SharePoint.PowerShell