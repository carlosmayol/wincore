$query = @"
<QueryList>
  <Query Id="0" Path="System">
    <Select Path="System">*[System[Provider[@Name='Microsoft-Windows-FailoverClustering'] and (EventID=5120) and TimeCreated[timediff(@SystemTime) &lt;= 10000]]]</Select>
  </Query>
</QueryList>
"@

#Time value is in ms

$servers = "lab6_ws2019_05", "lab6_ws2019_06"

$ErrorActionPreference = "SilentlyContinue"

#Get current date/time
$Date = Get-Date -f yyyy_MM_dd_hhmmss

[bool]$5120 = $false

do
{
    Start-Sleep 1

    ForEach ($server in $servers) {
     
     $events = Get-WinEvent -FilterXml $query -ComputerName $server

     if ($events.count -gt '0')

        {
        ForEach ($Event in $Events) {
        # Convert the event to XML
        $eventXML = ([xml]$Event.ToXml()).Event.EventData.Data
      
        Add-Member -InputObject $Event -MemberType NoteProperty -Force -Name  ComputerName -Value $event.MachineName
        Add-Member -InputObject $Event -MemberType NoteProperty -Force -Name  VolumeName -Value $eventXML[0].'#text'
	    Add-Member -InputObject $Event -MemberType NoteProperty -Force -Name  ErrorCode -Value $eventXML[2].'#text'
        Add-Member -InputObject $Event -MemberType NoteProperty -Force -Name  TimeCreated -Value $event.TimeCreated

        $events | ft ComputerName, VolumeName, ErrorCode, TimeCreated

        }

  
        if ($eventXML[0].'#text' -eq "Volume01" -and $eventXML[2].'#text' -eq "STATUS_IO_TIMEOUT(c00000b5)") {
            $5120 = $true
            write-host "5120 found on node $server"}
        }
    
        else {Write-Host "`." -NoNewline }
            
    }

    
}
until ($5120)






