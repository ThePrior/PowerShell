
Add-Type -TypeDefinition @"
   public enum AWP_LogLevel
   {
    LEVEL_OFF = 0,
    LEVEL_ALL = 1,
    LEVEL_INFO_AND_ABOVE = 2,
    LEVEL_WARN_AND_ABOVE = 3,
    LEVEL_ERROR_ONLY = 4
   }
"@

Function StartLog {
    Param(
        [Parameter(Mandatory=$true)]
        [string] $logName
    )
	$script:StartTime =  Get-Date
    $script:msg = New-Object System.Text.StringBuilder
	$global:scriptName = $logName
}

Function WriteLog($text, $color) {

    [void]$script:msg.AppendLine($text)
    if ($color) {
        Write-Host $text -Fore $color
    } else {
        Write-Output $text
    }
}

Function SaveLog( ) {
    $dayOfWeek = $(get-date).DayOfWeek
    $hour = $(get-date).Hour
    $minute = $(get-date).Minute


    $elapsedTime = $(get-date) - $script:StartTime
    $totalTime = "{0:HH:mm:ss}" -f ([datetime]$elapsedTime.Ticks)

    $txt = "INFO - Time taken = $totalTime"
	[void]$script:msg.AppendLine($txt)
	
	$txt = "End Time: $(get-date)"
	[void]$script:msg.AppendLine($txt) 
	
	$fullMsgString = $script:msg.ToString()
	
    New-Item -ItemType Directory -Force -Path ".\logs" | Out-Null
    Set-Content -Path ".\logs\$global:scriptName-$dayOfWeek-$hour-$minute.log" -Value $fullMsgString
}


Function Log-Verbose ( $message ) {
    if ( $script:logLevel -eq [AWP_LogLevel]::LEVEL_ALL ) {
		WriteLog -text "$(get-date) - VERBOSE: $message" -color Gray		
    }
}

Function Log-Info ( $message ) {
    if ( $script:logLevel -eq [AWP_LogLevel]::LEVEL_ALL -or $script:logLevel -eq [AWP_LogLevel]::LEVEL_INFO_AND_ABOVE ) {
		WriteLog -text "$(get-date) - INFO: $message" -color Green
    }
}


Function Log-Warn ( $message ) {
    if ( $script:logLevel -eq [AWP_LogLevel]::LEVEL_ALL -or $script:logLevel -eq [AWP_LogLevel]::LEVEL_INFO_AND_ABOVE -or $script:logLevel -eq [AWP_LogLevel]::LEVEL_WARN_AND_ABOVE) {
        WriteLog -text "$(get-date) - WARN: $message" -color Yellow
    }
}

Function Log-Error ( $message ) {
    if ( $script:logLevel -ne [AWP_LogLevel]::LEVEL_OFF) {
        WriteLog -text "$(get-date) - ERROR: $message" -color Red 
    }
}
Function HandleException () {

	$errorMsg = $PSItem.Exception.Message	
	Log-Error ("", $errorMsg) -ForegroundColor Red 


	$formatstring = "{0} : {1}`n{2}`n" +
					"    + CategoryInfo          : {3}`n" +
					"    + FullyQualifiedErrorId : {4}`n"
	$fields = $_.InvocationInfo.MyCommand.Name,
			  $_.ErrorDetails.Message,
			  $_.InvocationInfo.PositionMessage,
			  $_.CategoryInfo.ToString(),
			  $_.FullyQualifiedErrorId

	$errorMsg = $formatstring -f $fields
	Log-Error ("", $errorMsg) -ForegroundColor Gray 

}
