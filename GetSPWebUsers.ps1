Add-PsSnapin Microsoft.SharePoint.PowerShell

$webUrl=$args[0]
$webUrl = "http://W2K12R2/customers/WRS"

$CurrentDir = Resolve-Path .
$logfile=$CurrentDir.Path + "\GetSPWebUsers.log"

Start-Transcript $logfile -Append

$web = get-spweb $webUrl

$siteUsers = $web.SiteUsers 
 
	

    foreach($user in $web.AllUsers) 
    {        
        Write-Host " ------------------------------------- " 
        Write-Host "URL:", $webUrl 

        if($user.IsSiteAdmin -eq $true) 
        { 
            Write-Host "ADMIN: ", $user.LoginName $user.UserToken.BinaryToken.Length

            if ($user.LoginName -eq 'i:0#.w|w2k12r2\dppqueuemanager'){
                Write-Host "FOUND: ",  $web.AllUsers[$user.LoginName].UserToken.BinaryToken.Length
            }
        } 
        else 
        { 
            Write-Host "USER: ", $user.LoginName $user.UserToken.BinaryToken.Length
        } 

 
        Write-Host " ------------------------------------- " 
    }    
    
$web.dispose()

Stop-Transcript 

Remove-PsSnapin Microsoft.SharePoint.PowerShell