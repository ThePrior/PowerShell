# TODO: DO THIS BIT LAST AND USE SITE NAME TO COMPOSE GROUP NAME?

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
"Meeting Workflow5 Site Members","Meeting Workflow5 Site Owners","Meeting Workflow5 Site Visitors",
"Meeting Workspace Approved Members","Meeting Workspace Approved Owners","Meeting Workspace Approved Visitors",
"New Site From Team Template Members","New Site From Team Template Owners","New Site From Team Template Visitors",
"Quality & Standards Members","Quality & Standards Owners","Quality & Standards Visitors",
"Quick Deploy Users",
"Restricted Readers",
"Style Resource Readers",
"Swindon LDU Members","Swindon LDU Owners","Swindon LDU Readers",
"Team Site Template Test Members","Team Site Template Test Owners","Team Site Template Test Visitors",
"test team site Members","test team site Owners","test team site Visitors",
"Translation Managers",
"trial2 Members","trial2 Owners","trial2 Visitors",
"trial meeting workspace Members","trial meeting workspace Owners","trial meeting workspace Visitors",
"Trustwide Members","Trustwide Owners","Trustwide Visitors",
"walkthrough Members","walkthrough Owners","walkthrough Visitors",
"Workflow3 site Members","Workflow3 site Owners","Workflow3 site Visitors",
"Wotkflow4 site Members","Wotkflow4 site Owners","Wotkflow4 site Visitors"
)

$groups = $spGroups | ? {$_.Name -notin $doNotDeleteGroupNames}
Write-Host "Found" $groups.Count "groups for deletion:"

ForEach($group in $groups) {
   Write-Host $group.Name
   #Write-Host "Deleting" $group.Name "..."
   #$spGroups.Remove($group.Name) 
}

$spWeb.Dispose()

