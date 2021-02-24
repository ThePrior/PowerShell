# By Tom Chantler - https://tomssl.com/2019/04/30/a-better-way-to-add-and-remove-windows-hosts-file-entries/
param([string]$Hostname = "ourspace"
	,[string]$DesiredIP = "10.238.241.95"
	,[bool]$CheckIPAddressOnly = $true)	

# Comment out matching entry from hosts file. 

#Requires -RunAsAdministrator
$hostsFilePath = "$($Env:WinDir)\system32\Drivers\etc\hosts"

$newLines = @()

#Write-Host "About to comment out $DesiredIP from hosts file" -ForegroundColor Gray

$escapedHostname = [Regex]::Escape($Hostname)
$patternToMatch = If ($CheckIPAddressOnly) { ".*$DesiredIP.*" } Else { ".*$DesiredIP\s+$escapedHostname.*" }

$matchCnt = 0
$matchFound = $false
foreach($line in [System.IO.File]::ReadLines($hostsFilePath))
{
    if ($line -match $patternToMatch -and $line[0] -ne "#")  {
        $matchFound = $true
        $matchCnt++
        #Write-Host "$Hostname - commenting out from hosts file... " -ForegroundColor Yellow 
        $newLine = "#" + $line
        $newLines += $newLine
    } else {
        $newLines += $line
    }
}

#Write-Host "$matchCnt lines matching $DesiredIP found"

if (!$matchFound) {
    Write-Host "Warning: no match found in hosts file for $DesiredIP" -ForegroundColor Yellow
}

If ($matchFound)  {
    $success = $false
    do {
        try {
            #Write-Host "$DesiredIP - commenting out entry(s) in hosts file... " -ForegroundColor Yellow -NoNewline
            Clear-Content $hostsFilePath -ErrorAction Stop
            foreach ($line in $newLines) {
                $line | Out-File -encoding UTF8 -append $hostsFilePath -ErrorAction Stop
            }

            $success = $true

        } catch {
            echo $_.Exception.Message
            Write-Host "Retrying... "
            Start-Sleep -Seconds 1
        }
    } while (!$success)
} 
Else {
    #Write-Host "$DesiredIP - not in hosts file (perhaps already removed); nothing to do" -ForegroundColor DarkYellow
}