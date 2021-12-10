<#
#Looking to the template event structure
$event = Get-Winevent -ListProvider Microsoft-Windows-FailoverClustering-CsvFs-Operational
$event.Events | ? {$_.id -eq 9296}

Id          : 9296
Version     : 0
LogLink     : System.Diagnostics.Eventing.Reader.EventLogLink
Level       : System.Diagnostics.Eventing.Reader.EventLevel
Opcode      : System.Diagnostics.Eventing.Reader.EventOpcode
Task        : System.Diagnostics.Eventing.Reader.EventTask
Keywords    : {, ms:Measures, VolumeState}
Template    : <template xmlns="http://schemas.microsoft.com/win/2004/08/events">
                <data name="Volume" inType="win:Pointer" outType="win:HexInt64"/>
                <data name="VolumeId" inType="win:GUID" outType="xs:GUID"/>
                <data name="CountersName" inType="win:UnicodeString" outType="xs:string"/>
                <data name="FromDirectIo" inType="win:Boolean" outType="xs:boolean"/>
                <data name="Irp" inType="win:Pointer" outType="win:HexInt64"/>
                <data name="Status" inType="win:HexInt32" outType="win:HexInt32"/>
                <data name="Source" inType="win:UInt32" outType="xs:unsignedInt"/>
                <data name="Parameter1" inType="win:HexInt64" outType="win:HexInt64"/>
                <data name="Parameter2" inType="win:HexInt64" outType="win:HexInt64"/>
                <data name="LastUptime" inType="win:UInt64" outType="xs:unsignedLong"/>
                <data name="CurrentDowntime" inType="win:UInt64" outType="xs:unsignedLong"/>
                <data name="TimeSinceLastStateTransition" inType="win:UInt64" outType="xs:unsignedLong"/>
                <data name="Lifetime" inType="win:UInt64" outType="xs:unsignedLong"/>
              </template>
Description : Volume %2 is autopaused. Status %6. Source: %7.
#>

<# source 
  typedef enum _CSVFS_VOLUME_AUTOPAUSE_SOURCE {
    CsvFsVolumeAutopauseFromUnknown                                       = 0x00,
    CsvFsVolumeAutopauseFromTunnel                                        = 0x01,
    CsvFsVolumeAutopauseFromBRLReaplyDownLevelLock                        = 0x02,
    CsvFsVolumeAutopauseFromBRLUnlockAll                                  = 0x03,
    CsvFsVolumeAutopauseFromBRLUnlock                                     = 0x04,
    CsvFsVolumeAutopauseFromCADFOResumeComplete                           = 0x05,
    CsvFsVolumeAutopauseFromCAPFOResumeComplete                           = 0x06,
    CsvFsVolumeAutopauseFromCAPFOSetBypass                                = 0x07,
    CsvFsVolumeAutopauseFromCASuspendOnClose                              = 0x08,
    CsvFsVolumeAutopauseFromUnregisterScb                                 = 0x09,
    CsvFsVolumeAutopauseFromBRLUnlockAllOnCleanup                         = 0x0a,
    CsvFsVolumeAutopauseFromUserRequest                                   = 0x0b,
    CsvFsVolumeAutopauseFromOplockTryStopLocalBufferingCachePurgeFailed   = 0x0c,
    CsvFsVolumeAutopauseFromOplockTryStopLocalAdvanceVdlToDiskToVdl       = 0x0d,
    CsvFsVolumeAutopauseFromOplockTryStopLocalBufferingCacheFlushFailed   = 0x0e,
    CsvFsVolumeAutopauseFromOplockTryDowngradeBufferingAsyncIrpAllocate   = 0x0f,
    CsvFsVolumeAutopauseFromOplockTryStopLocalBuffering                   = 0x10,
    CsvFsVolumeAutopauseFromOplockSetMaxOplock                            = 0x11,
    CsvFsVolumeAutopauseFromFltAckOplockBreak                             = 0x12,
    CsvFsVolumeAutopauseFromAckOplockBreak                                = 0x13,
    CsvFsVolumeAutopauseFromTryDowngradeBufferingAsync                    = 0x14,
    CsvFsVolumeAutopauseFromUpgradeOplock                                 = 0x15,
    CsvFsVolumeAutopauseFromQueryOplockStatus                             = 0x16,
    CsvFsVolumeAutopauseFromSingleClientNotifyComplete                    = 0x17,
    CsvFsVolumeAutopauseFromSingleClientNotifyUnregisterScb               = 0x18,
    CsvFsVolumeAutopauseFromSingleClientNotifyStart                       = 0x19,
    CsvFsVolumeAutopauseFromOplockCompleted                               = 0x1a,
    CsvFsVolumeAutopauseFromSetDownLevelSetFileDisposition                = 0x1b,
    CsvFsVolumeAutopauseFromReconnectScb                                  = 0x1c,
    CsvFsVolumeAutopauseFromReconnectVcb                                  = 0x1d,
    CsvFsVolumeAutopauseFromIOCompletion                                  = 0x1e,
    CsvFsVolumeAutopauseFromOplockTryStartLocalBufferingCachePurgeFailed  = 0x1f,
    CsvFsVolumeAutopauseFromSetPurgeFailureMode                           = 0x20,
    CsvFsVolumeAutopauseFromMarkHandleSkipCoherencySyncDisallowWrites     = 0x21,
    CsvFsVolumeAutopauseFromOpenPagingFileObject                          = 0x22, 
    #>


$Date = Get-Date -f yyyy_MM_dd_hhmmss
$evtxs = Get-ChildItem -Path .\ -Filter "Microsoft-Windows-FailoverClustering-CsvFs-Operational.EVTX" -Recurse
$evtxpath = ($evtxs).fullname

foreach ($querypath in $evtxpath) {
    $events = Get-WinEvent -FilterHashtable @{Path="$querypath";Id=9296} -MaxEvents 100
    ForEach ($Event in $Events) {
        # Convert the event to XML
        $eventXML = ([xml]$Event.ToXml()).Event.EventData.Data
        Add-Member -InputObject $Event -MemberType NoteProperty -Force -Name  ComputerName -Value $event.MachineName
        Add-Member -InputObject $Event -MemberType NoteProperty -Force -Name  CountersName -Value $eventXML[2].'#text'
        Add-Member -InputObject $Event -MemberType NoteProperty -Force -Name  FromDirectIo -Value $eventXML[3].'#text'
	    Add-Member -InputObject $Event -MemberType NoteProperty -Force -Name  Irp -Value $eventXML[4].'#text'
        Add-Member -InputObject $Event -MemberType NoteProperty -Force -Name  Status -Value $eventXML[5].'#text'
        Add-Member -InputObject $Event -MemberType NoteProperty -Force -Name  Source -Value $eventXML[6].'#text'
        Add-Member -InputObject $Event -MemberType NoteProperty -Force -Name  Parameter1 -Value $eventXML[7].'#text'
        Add-Member -InputObject $Event -MemberType NoteProperty -Force -Name  Parameter2 -Value $eventXML[8].'#text'
        Add-Member -InputObject $Event -MemberType NoteProperty -Force -Name  LastUptime -Value $eventXML[9].'#text'
        Add-Member -InputObject $Event -MemberType NoteProperty -Force -Name  CurrentDowntime -Value $eventXML[10].'#text'
        Add-Member -InputObject $Event -MemberType NoteProperty -Force -Name  TimeSinceLastStateTransition -Value $eventXML[11].'#text'
        Add-Member -InputObject $Event -MemberType NoteProperty -Force -Name  Lifetime -Value $eventXML[12].'#text'
        Add-Member -InputObject $Event -MemberType NoteProperty -Force -Name  TimeCreated -Value $event.TimeCreated
        
        }

        $report += $events       
    }

    $report | ft Computername, CountersName, Irp, Status, Source, Parameter1, Parameter2, LastUptime, TimeSinceLastStateTransition, TimeCreated -AutoSize
    $report | Group-Object -Property Status, Source | Ft Name, Count
