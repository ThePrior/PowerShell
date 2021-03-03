cls

$ErrorActionPreference = "Stop"

Add-Type -assembly "Microsoft.Office.Interop.Outlook"
Add-Type -assembly "System.Runtime.Interopservices"

$EmailTo = "peter.core@nhs.net"

$WordDocumentUrl = "http://ourspace/SystemTest/Shared%20Documents/Hello%20World.docx?d=wc35d546a8af949cda1c3fdc56160ebdf&Source=http%3A%2F%2Fourspace%2FSystemTest%2FShared%2520Documents%2FForms%2FAllItems%2Easpx"

$global:outlookWasAlreadyRunning = $true
$global:pingFailure = $false

Function Send-Email( $outlook, $wfe, $url, $message ){
    #create Outlook MailItem named Mail using CreateItem() method
    $Mail = $Outlook.CreateItem(0)

    #add properties as desired
    $Mail.To = $EmailTo
    $Mail.Subject = "Ping Servers Error - $wfe not responding as expected " 
    $Mail.Body = "Error ON $wfe -------- Error accessing $url. Error Message: $message"

    #send message
    $Mail.Send()
}

Function NavigateTo([string] $url, [string] $wfe, $page, $hostHeaderArray, $searchString)  {
    
    if ( $hostHeaderArray -eq $null) {
        $hostHeaderArray = @{ "Cache-Control"="no-cache" }
    } else {
        $hostHeaderArray.Add( "Cache-Control", "no-cache" )
    }

	if ($url.ToUpper().StartsWith("HTTP") -and !$url.EndsWith("/ProfileService.svc","CurrentCultureIgnoreCase")) {
		#WriteLog "  $url" -NoNewLine
		# WebRequest command line
        Write-Host "Attempting to access" $wfe $page "..."
		try {
			$wr = Invoke-WebRequest -Uri $url -Headers $hostHeaderArray -UseBasicParsing -UseDefaultCredentials -TimeoutSec 120
			#FetchResources $url $wr.Images
			#FetchResources $url $wr.Scripts
            if ( $wr.Content -like $searchString ) {
    			Write-Host $wfe "OK" -ForegroundColor Green
            } else {
                $message ="Expected string '$searchString' not found in HTML content from ", $wfe
                Write-Host $message -ForegroundColor Red
                $global:pingFailure = $true
                Send-Email -outlook $outlook -wfe $wfe -url $url -message $message
            }
		} catch {
    		Write-Host ("Problem with ", $wfe) -ForegroundColor Red
            echo $_.Exception | format-list -force
			$httpCode = $_.Exception.Response.StatusCode.Value__
			if ($httpCode) {
				Write-Host "HttpCode = [$httpCode]" -ForegroundColor Yellow
            }

            $global:pingFailure = $true
            Send-Email -outlook $outlook -wfe $wfe -url $url -message $_.Exception.Message
		}
	}
}

Function Test-Server([string] $ipAddress, [string] $wfe) {
    .\AddToHosts.ps1  -DesiredIP $ipAddress -CheckIPAddressOnly $true
    NavigateTo "http://Ourspace" $wfe "Ourspace Home Page" -searchString "*Ourspace Homepage*"
    NavigateTo "http://meetingportal.awp.nhs.uk/sites/meetings" $wfe "Meetings" -searchString  "*AWP Meeting Portal*"
    NavigateTo "http://myspace.awp.nhs.uk/person.aspx" $wfe "MySpace" @{ host="myspace.awp.nhs.uk" } -searchString  "*About Core, Peter*"
    .\RemoveFromHosts.ps1 -DesiredIP $ipAddress5 -CheckIPAddressOnly $true
}

Function Start-Outlook-OLD_VERSON() {

    $outlook = $null
    try
    {
        $outlook = [Runtime.Interopservices.Marshal]::GetActiveObject('Outlook.Application')
        $global:outlookWasAlreadyRunning = $true
    }
    catch
    {
        try
        {
            $outlook = New-Object -ComObject Outlook.Application
            $global:outlookWasAlreadyRunning = $false
        }
        catch
        {
            $_.Exception
            write-host "You must run Outlook as an Administrator for this to work." -ForegroundColor Red
            exit
        }
    }
    return $outlook

}

Function Start-Outlook() {

    $outlook = $null
    try
    {
        $outlook = [Runtime.Interopservices.Marshal]::GetActiveObject('Outlook.Application')
        $global:outlookWasAlreadyRunning = $true
    }
    catch
    {
        Write-Host "It is best if Outlook is already running (in Administrator mode) for this to work." -ForegroundColor Red
        #Write-Host $_.Exception
        Exit

        # Old code which starts Outlook - does work, but probably not what's wanted.
        try
        {
            $outlook = New-Object -ComObject Outlook.Application
            $global:outlookWasAlreadyRunning = $false
        }
        catch
        {
            Write-Host $_.Exception
            write-host "You must run Outlook as an Administrator for this to work." -ForegroundColor Red
            exit
        }
    }
    return $outlook

}

Function Exit_Outlook() {

    # Close outlook if it wasn't opened before running this script
    if ($global:outlookWasAlreadyRunning -eq $false) {
            
        $outlook.Quit() 
        [System.Runtime.Interopservices.Marshal]::ReleaseComObject($Outlook) | Out-Null

        Start-Sleep -Seconds 2

        Get-Process "*outlook*" | Stop-Process –force
    }
}

cd $PSScriptRoot

$outlook = Start-Outlook 


# Ping the Urls on the servers and search returned HTML body content for expected strings

while (!$global:pingFailure) {

    Test-Server -ipAddress 10.238.241.95 -wfe WFE11
    Test-Server -ipAddress 10.238.241.96 -wfe WFE12
    Test-Server -ipAddress 10.238.241.103 -wfe WFE21
    Test-Server -ipAddress 10.238.241.104 -wfe WFE22

    .\AddToHosts.ps1  -DesiredIP 10.238.241.99 -CheckIPAddressOnly $true
    NavigateTo -url "https://rvn-oos-pool-1.awp.nhs.uk/hosting/discovery" -wfe "OOS11" -page "WOPI Discovery" -searchString "*wopi-discovery*"
    NavigateTo -url $WordDocumentUrl -wfe "OOS11" -page "Hello World.docx" -searchString "*Hello World*"  
    .\RemoveFromHosts.ps1 -DesiredIP 10.238.241.99 -CheckIPAddressOnly $true

    .\AddToHosts.ps1  -DesiredIP 10.238.241.107 -CheckIPAddressOnly $true
    NavigateTo -url "https://rvn-oos-pool-1.awp.nhs.uk/hosting/discovery" -wfe "OOS21" -page "WOPI Discovery" -searchString "*wopi-discovery*"
    NavigateTo -url $WordDocumentUrl -wfe "OOS21" -page "Hello World.docx" -searchString "*Hello World*"  
    .\RemoveFromHosts.ps1 -DesiredIP 10.238.241.107 -CheckIPAddressOnly $true

    if (!$global:pingFailure){
        Write-Host $(Get-Date -DisplayHint Time) -ForegroundColor Gray
        Write-Host "Sleeping for 1 minute before next ping..." -ForegroundColor Gray
        Start-Sleep -Seconds 15
        Write-Host "... 45 seconds"  -ForegroundColor Gray
        Start-Sleep -Seconds 15
        Write-Host "... 30 seconds"  -ForegroundColor Gray
        Start-Sleep -Seconds 15
        Write-Host "... 15 seconds"  -ForegroundColor Gray
        Start-Sleep -Seconds 15
        Write-Host "... let's go"  -ForegroundColor Gray
    } else {
        Write-Host "Ping error exiting script..." -ForegroundColor Red
        Write-Host "Please investigate the error then re-run this script once resolved..." -ForegroundColor Yellow
    }
}

Exit_Outlook 