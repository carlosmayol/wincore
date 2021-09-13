https://docs.microsoft.com/en-us/windows-server/storage/storage-spaces/data-collection

#Automatic report on a given path:

#find the latest diagnostic zip in UserProfile
    $DiagZip=(get-childitem $env:USERPROFILE | where Name -like HealthTest*.zip)
    $LatestDiagPath=($DiagZip | sort lastwritetime | select -First 1).FullName
#expand to temp directory
    New-Item -Name SDDCDiagTemp -Path d:\ -ItemType Directory -Force
    Expand-Archive -Path $LatestDiagPath -DestinationPath c:\SDDCDiagTemp -Force
#generate report and save to text file
    $report=Show-SddcDiagnosticReport -Path D:\SDDCDiagTemp
    $report | out-file d:\SDDCReport.txt
	
#Manual report with no storage latency report (screen only)
Show-SddcDiagnosticReport -Path .\ -ReportLevel Full -Report  Summary, SmbConnectivity, StorageBusCache, StorageBusConnectivity, StorageFirmware, LSIEvent

#Latency report: Show-SddcDiagnosticStorageLatencyReport -> Report provides access to time/latency cutoff limits which may significantly speed up reporting when focused on recent high latency events
Show-SddcDiagnosticStorageLatencyReport -Path .\ -ReportLevel Standard -Days 5 -CutoffMs 1    