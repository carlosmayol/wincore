<#

#Looking to the template event structure
$healthevent = Get-Winevent -ListProvider Microsoft-Windows-Health
$healthevent.Events | ? {$_.id -eq 8465}

->
Description : ChangeType: %1
              Severity: %2
              Source: %3
              Resource Name: %4
              Resource Type: %5
              Title: %6
              Description: %7
              Remediation: %8
              Fault Type Id: %9
              Fault: %10


#>

#v1.0 Script

$Healthquery = @"
<QueryList>
  <Query Id="0" Path="Microsoft-Windows-Health/Operational">
    <Select Path="Microsoft-Windows-Health/Operational">*[System[(EventID=8465)]]</Select>
  </Query>
</QueryList>
"@

#Get current date/time
$Date = Get-Date -f yyyy_MM_dd_hhmmss

$servers = "lab6_ws2019_05", "lab6_ws2019_06"

ForEach ($server in $servers) {
    $events = Get-WinEvent -FilterXml $Healthquery -ComputerName $server

    ForEach ($Event in $Events) {
        # Convert the event to XML
        $eventXML = ([xml]$Event.ToXml()).Event.EventData.Data
      
        Add-Member -InputObject $Event -MemberType NoteProperty -Force -Name  ChangeType -Value $eventXML[0].'#text'
        Add-Member -InputObject $Event -MemberType NoteProperty -Force -Name  Severity -Value $eventXML[1].'#text'
	Add-Member -InputObject $Event -MemberType NoteProperty -Force -Name  Source -Value $eventXML[2].'#text'
        Add-Member -InputObject $Event -MemberType NoteProperty -Force -Name  ResourceName -Value $eventXML[3].'#text'
        Add-Member -InputObject $Event -MemberType NoteProperty -Force -Name  ResourceType -Value $eventXML[4].'#text'
        Add-Member -InputObject $Event -MemberType NoteProperty -Force -Name  Title -Value $eventXML[5].'#text'
        Add-Member -InputObject $Event -MemberType NoteProperty -Force -Name  Description -Value $eventXML[6].'#text'
        Add-Member -InputObject $Event -MemberType NoteProperty -Force -Name  Remediation -Value $eventXML[7].'#text'
        Add-Member -InputObject $Event -MemberType NoteProperty -Force -Name  FaultTypeId -Value $eventXML[9].'#text'
        Add-Member -InputObject $Event -MemberType NoteProperty -Force -Name  Fault -Value $eventXML[9].'#text'
    }
    write-host "Showing events 8465 for server $server" -ForegroundColor Yellow
    $Events | ft TimeCreated, ChangeType, Severity, ResourceName, Description -AutoSize #some fields ommited here
    $Events | Export-Csv -Path .\$date-HealthEvents.csv -Append -NoTypeInformation
}
