  #[void][System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms")|Out-Null 

  #https://stackoverflow.com/questions/32381042/powershell-prompt-for-would-you-like-to-continue
   Function Show-MsgBox ($Text,$Title="",[Windows.Forms.MessageBoxButtons]$Button = "OK",[Windows.Forms.MessageBoxIcon]$Icon="Information"){
     [Windows.Forms.MessageBox]::Show("$Text", "$Title", [Windows.Forms.MessageBoxButtons]::$Button, $Icon) | ?{(!($_ -eq "OK"))}
   }


   if((Show-MsgBox -Title 'Confirm CleanUp' -Text 'Warning: this scripts deletes user groups and optionally sites. Are you sure you want to continue?'-Button YesNo -Icon Warning) -eq 'No'){
     Exit
   }