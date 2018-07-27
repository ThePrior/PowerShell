Add-PsSnapin Microsoft.SharePoint.PowerShell

$siteUrl=$args[0]
$listName = $args[1]

$CurrentDir = Resolve-Path .
$logfile=$CurrentDir.Path + "\DeleteListItemsBatch.log"

Start-Transcript $logfile 

# Enter your configuration here
$batchSize = 500

write-host "Opening web at $siteUrl..."

$site = new-object Microsoft.SharePoint.SPSite($siteUrl)
$web = $site.OpenWeb()
write-host "Web is: $($web.Title)"

$list = $web.Lists[$listName];
write-host "List is: $($list.Title)"

while ($list.ItemCount -gt 0)
{
  write-host "Item count: $($list.ItemCount)"

  $batch = "<?xml version=`"1.0`" encoding=`"UTF-8`"?><Batch>"
  $i = 0

  $collListItems = $list.Items;
  foreach ($item in $collListItems)
  {
    $i++
    write-host "`rProcessing ID: $($item.ID) ($i of $batchSize)" -nonewline

    $batch += "<Method><SetList Scope=`"Request`">$($list.ID)</SetList><SetVar Name=`"ID`">$($item.ID)</SetVar><SetVar Name=`"Cmd`">Delete</SetVar><SetVar Name=`"owsfileref`">$($item.File.ServerRelativeUrl)</SetVar></Method>"

    if ($i -ge $batchSize) { break }
  }

  $batch += "</Batch>"

  write-host

  write-host "Sending batch..."

  # We execute it 
  $result = $web.ProcessBatchData($batch)

  write-host "Emptying Recycle Bin..."

  # We remove items from recyclebin
  $web.RecycleBin.DeleteAll()

  write-host

  $list.Update()
}

write-host "Done."

Write-Host " ------------------------------------- " 
    
$web.dispose()

Stop-Transcript 

Remove-PsSnapin Microsoft.SharePoint.PowerShell