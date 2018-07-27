
#Region Configure Site Permissions
Function ConfigureSiteCustomPermissions([xml]$xmlinput){
    WriteLine
    Write-Host -ForegroundColor White " - Adding custom permissions to site collection groups..."

	ForEach($node in $xmlinput.SelectNodes("//site")){
		$siteUrl = (GetFromNode $node "siteUrl")
      
		$web = get-spweb $siteUrl

        Write-Host -ForegroundColor White " - creating new groups and permissions for" $web.Title $web.Url
		
        foreach ($groupNode in $node.groups.group){

            $permissions = GetFromNode $groupNode "permissions"
            $permissionsNode = $xmlinput.SelectSingleNode("//permissions/" + $permissions)

            $permLevelName = GetFromNode $permissionsNode "permLevelName"
            $permLevelDesc = GetFromNode $permissionsNode "permLevelDesc"
            $permissions = GetFromNode $permissionsNode "permissions"

            $permLevel = CreatePermissionLevel $web $permLevelName $permLevelDesc $permissions

            $groupName = GetFromNode $groupNode "groupName"
            $group = CreateGroup $web $groupName

            AddUsersToGroup $web $group $groupNode

            $superUserGroupAssignment = New-Object Microsoft.SharePoint.SPRoleAssignment($group)
            $superUserGroupAssignment.RoleDefinitionBindings.Add($permLevel)
            $web.RoleAssignments.Add($superUserGroupAssignment)

        }

        $web.Update()
        $web.Dispose()
	}

	WriteLine
}

Function CreatePermissionLevel($web, $permLevelName, $permLevelDesc, $permLevelPermissions){
    
        # If this is not a built in permission level, the permissions string will not be empty. In this case delete the RoleDefinition so it can be updated.
        if (![string]::IsNullOrEmpty($permLevelPermissions) -and $web.RoleDefinitions[$permLevelName] -ne $null){
            $web.RoleDefinitions.Delete($permLevelName)
        }
        
        $exists = $false
        foreach ($roleDefn in $web.RoleDefinitions){
            if ($roleDefn.Name -eq $permLevelName){
                return $roleDefn
            }
        }

        if (!$exists){
            Write-Host -ForegroundColor White "Creating custom permission level: " $permLevelName
            	
		    $permSuperUser = New-Object Microsoft.SharePoint.SPRoleDefinition
            $permSuperUser.Name = $permLevelName
            $permSuperUser.Description = $permLevelDesc
            $permSuperUser.BasePermissions = $permLevelPermissions
            $web.RoleDefinitions.Add($permSuperUser)
            $web.Update()
        }

        foreach ($roleDefn in $web.RoleDefinitions){
            if ($roleDefn.Name -eq $permLevelName){
                return $roleDefn
            }
        }
}

Function CreateGroup($web, $groupName){
    
        $group = $web.SiteGroups[$groupName]
        if ($group -eq $null){         
		    Write-Host -ForegroundColor White "Creating group: " $groupName " in " $web.Title
            $web.SiteGroups.Add($groupName, $web.Site.Owner, $web.Site.Owner, $groupDesc)
            $group = $web.SiteGroups[$groupName]
            $group.AllowMembersEditMembership = $true
            $group.Update()
            $web.Update()
        }

        return $group
}

Function AddUsersToGroup($web, $group, $groupNode){
    
    foreach($groupMember in $groupNode.groupMembers.groupMember){
        $userName = GetFromNode $groupMember "name"
        Write-Host -ForegroundColor White "Adding user or group: " $userName " to: " $group        
        $user = $web.EnsureUser($userName)
        $group.AddUser($user)
        $group.Update()
    }
}

#Region Configure Site Users
Function ConfigureSiteUsers([xml]$xmlinput)
{
    WriteLine
    Write-Host -ForegroundColor White " - Adding new users or groups to site collection groups..."

    ForEach($node in $xmlinput.SelectNodes("//site"))
    {
        $siteUrl = (GetFromNode $node "siteUrl")
        $web = get-spweb $siteUrl

		ForEach($user in $node.SelectNodes("user"))
		{
			$userOrGroupName = (GetFromNode $user "userOrGroupName")
			$addToSharePointGroup = (GetFromNode $user "addToSharePointGroup")
			
			$spAccount = $web.EnsureUser($userOrGroupName)
			$spGroup = $web.SiteGroups[$addToSharePointGroup]
			
            $userOrGroupAlreadyAdded = $spGroup.Users | where { $_.DisplayName -eq $userOrGroupName }

            if ($userOrGroupAlreadyAdded -eq $null)
            {
                Write-Host "Adding " $userOrGroupName " to " $addToSharePointGroup " for Site: " $siteUrl 
			
                $spGroup.AddUser($spAccount)
                $spGroup.Update()
            }
            
		}

        $web.Dispose()
	}
	
	WriteLine
}
#EndRegion

#Region Utilitiy Functions
Function GetFromNode([System.Xml.XmlElement]$node, [string] $item)
{
    $value = $node.GetAttribute($item)
    If ($value -eq "")
    {
        $child = $node.SelectSingleNode($item);
        If ($child -ne $null)
        {
            Return $child.InnerText;
        }
    }
    Return $value;
}

# ====================================================================================
# Func: WriteLine
# Desc: Writes a nice line of dashes across the screen
# ====================================================================================
Function WriteLine
{
    Write-Host -ForegroundColor White "--------------------------------------------------------------"
}

#EndRegion

