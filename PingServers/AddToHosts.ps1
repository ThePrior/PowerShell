# By Tom Chantler - https://tomssl.com/2019/04/30/a-better-way-to-add-and-remove-windows-hosts-file-entries/
param([string]$Hostname = "ourspace"
	,[string]$DesiredIP = "10.238.241.95"
	,[bool]$CheckIPAddressOnly = $true)	

# Uncomments entry in the hosts file.

#Requires -RunAsAdministrator

$hostsFilePath = "$($Env:WinDir)\system32\Drivers\etc\hosts"

#Write-Host "About to uncomment out $DesiredIP from hosts file" -ForegroundColor Gray

$escapedHostname = [Regex]::Escape($Hostname)
$patternToMatch = If ($CheckIPAddressOnly) { ".*$DesiredIP.*" } Else { ".*$DesiredIP\s+$escapedHostname.*" }

$newLines = @()
$matchCnt = 0
$matchFound = $false
$contents = Get-Content $hostsFilePath

foreach($line in $contents)
{
    if ($line -match $patternToMatch -and $line[0] -eq "#")  {
        $matchFound = $true
        $matchCnt++
        $newLine = $line.Substring(1)
        $newLines += $newLine
    } else {
        $newLines += $line
    }
}


if (!$matchFound) {
    Write-Host "Warning: no match found in hosts file for $DesiredIP" -ForegroundColor Yellow
}

If ($matchFound)  {
    $success = $false
    do {
        try {
            #Write-Host "$DesiredIP - uncommented from hosts file... " -ForegroundColor Yellow -NoNewline
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
    #Write-Host "$DesiredIP - not commented out in hosts file nothing to do" -ForegroundColor DarkYellow
}

