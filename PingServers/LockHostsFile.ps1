$file = [System.io.File]::Open("$($Env:WinDir)\system32\Drivers\etc\hosts", 'Open', 'Read', 'None')
Read-Host 'Enter key to release file'
$file.Close()