# Fill in these variables with your values
$ServerList = "Cluster2016-1", "Cluster2016-2", "Cluster2016-3", "Cluster2016-4"


Invoke-Command ($ServerList) {
Set-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Services\spaceport\Parameters' -Name HwTimeout -Value 00007530
Get-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Services\spaceport\Parameters' -Name HwTimeout
}


Get-storagesubsystem clus* -cimsession Cluster2016-1 | set-storagehealthsetting -name "System.Storage.PhysicalDisk.AutoReplace.Enabled" -value "False"
