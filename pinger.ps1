$badconnection = $false
$starttime = $none
$endtime = $none
$counter = 0

$firstrun = Get-Date -Format "yyyyMMdd_HH_mm_ss"
$firstrun = "connection.log." + $firstrun + ".txt"
write-host "Logging to " $firstrun
$1sec = 10000000
$debug = $false

write-host -ForegroundColor yellow "Press any key to quit"
write-host "-----------------"


function Print-Connection-Status {
  [CmdletBinding()]
  param (
    [string]$ConnResult
  )
  write-host -NoNewLine ($counter).ToString('00000000') "connection "
  if ($ConnResult -like "OK")
  {
    write-host -ForegroundColor green $ConnResult
  } elseif ($ConnResult -like "NOK") {
    write-host -ForegroundColor red $ConnResult
  }
}

while ($true) {

  $result = (Test-Connection -ComputerName "index.hu" -Count 1  -Quiet)
  $counter++

#  DEBUG
  if ($debug -eq $true -and $counter -gt 1 -and $counter -lt 4)
  {
    $result = $false
  }


  if ($result -eq $false)
  {
    if ($badconnection -eq $false)
    {
        $starttime = Get-Date -Format "yyyy.MM.dd HH:mm:ss"
        $badconnection = $true
    }
    $endtime = Get-Date -Format "yyyy.MM.dd HH:mm:ss"

    Print-Connection-Status -ConnResult "NOK"

  } else {
    if ($badconnection -eq $true)
      {
        $begin = Get-Date -Date $starttime
        $end = Get-Date -Date $endtime
        $diff = $end - $begin + $1sec
        write-host -ForegroundColor yellow "In degraded mode: " $starttime " -> " $endtime " = " $diff
        $toWrite = $starttime + ";" + $endtime + ";" + $diff
         $toWrite >> $firstrun
        $badconnection = $false
      }

     Print-Connection-Status -ConnResult "OK"
  }

  Start-Sleep -Seconds 1

  if ([console]::KeyAvailable)
  {
    write-host -ForegroundColor yellow "Key pressed. End."
    write-host
    break
  }
}
