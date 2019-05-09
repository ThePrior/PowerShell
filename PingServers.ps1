
Function NavigateTo([string] $url, [string] $wfe, $hostHeaderArray)  {
	if ($url.ToUpper().StartsWith("HTTP") -and !$url.EndsWith("/ProfileService.svc","CurrentCultureIgnoreCase")) {
		#WriteLog "  $url" -NoNewLine
		# WebRequest command line
		try {
			$wr = Invoke-WebRequest -Uri $url -Headers $hostHeaderArray -UseBasicParsing -UseDefaultCredentials -TimeoutSec 120 
			#FetchResources $url $wr.Images
			#FetchResources $url $wr.Scripts
			Write-Host $wfe "OK"
		} catch {
			$httpCode = $_.Exception.Response.StatusCode.Value__
			if ($httpCode) {
				WriteLog "   [$httpCode]" Yellow
			} else {
				Write-Host " "
			}
		}
	}
}

Function WriteLog($text, $color) {
    $global:msg += "`n$text"
    if ($color) {
        Write-Host $text -Fore $color
    } else {
        Write-Output $text
    }
}

NavigateTo "http://10.238.241.95/Pages/Home.aspx" "WFE11 Home Page"
NavigateTo "http://10.238.241.96/Pages/Home.aspx" "WFE12 Home Page"
NavigateTo "http://10.238.241.103/Pages/Home.aspx" "WFE21 Home Page"
NavigateTo "http://10.238.241.104/Pages/Home.aspx" "WFE22 Home Page"

NavigateTo "http://10.238.241.95/sites/meetings/SitePages/Home.aspx" "WFE11 Meetings"
NavigateTo "http://10.238.241.96/sites/meetings/SitePages/Home.aspx" "WFE12 Meetings"
NavigateTo "http://10.238.241.103/sites/meetings/SitePages/Home.aspx" "WFE21 Meetings"
NavigateTo "http://10.238.241.104/sites/meetings/SitePages/Home.aspx" "WFE22 Meetings"

NavigateTo "http://10.238.241.95/sites/forms/Pages/FormsHome.aspx" "WFE11 Forms"
NavigateTo "http://10.238.241.96/sites/forms/Pages/FormsHome.aspx" "WFE12 Forms"
NavigateTo "http://10.238.241.103/sites/forms/Pages/FormsHome.aspx" "WFE21 Forms"
NavigateTo "http://10.238.241.104/sites/forms/Pages/FormsHome.aspx" "WFE22 Forms"

# Need to provide host header for this to work.
NavigateTo "http://10.238.241.95/person.aspx" "WFE11 MySpace" @{ host="myspace.awp.nhs.uk" }
NavigateTo "http://10.238.241.96/person.aspx" "WFE12 MySpace" @{ host="myspace.awp.nhs.uk" }
NavigateTo "http://10.238.241.103/person.aspx" "WFE21 MySpace" @{ host="myspace.awp.nhs.uk" }
NavigateTo "http://10.238.241.104/person.aspx" "WFE22 MySpace" @{ host="myspace.awp.nhs.uk" }

NavigateTo "https://rvn-sps-oos11.awp.nhs.uk/hosting/discovery" "OOS11"
NavigateTo "https://rvn-sps-oos21.awp.nhs.uk/hosting/discovery" "OOS21"

