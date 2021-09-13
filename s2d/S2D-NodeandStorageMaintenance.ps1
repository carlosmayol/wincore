$cluster = get-cluster -Domain $env:USERDOMAIN | Select-Object Name | Out-GridView -Title "Select your Cluster" -OutputMode Single 

$Node = Get-ClusterNode -Cluster $cluster.name | Select-Object Name | Out-GridView -Title "Select your Node to Drain" -OutputMode Single 

$NodeName = $Node.Name

Suspend-ClusterNode -Cluster $cluster.Name -Drain -Name $NodeName 

Get-StorageFaultDomain -type StorageScaleUnit -CimSession $cluster.Name | Where-Object {$_.FriendlyName -eq "$NodeName"} | Enable-StorageMaintenanceMode -CimSession $cluster.Name

Get-PhysicalDiskStorageNodeView -CimSession $NodeName | Where-Object {($_.IsPhysicallyConnected) -and ($_.StorageNodeObjectId -match "$NodeName")} | ft

Write-Verbose "Do your maintenance tasks and when ready press ENTER" -Verbose

Pause

#Run the Restart-Computer cmdlet to restart the node.

Restart-Computer -ComputerName $NodeName

Start-sleep 5

# Test for the Nodeto be back online and responding
while ((Invoke-Command -ComputerName $nodename -ScriptBlock {"Test"} -ErrorAction SilentlyContinue) -ne "Test") {Start-Sleep -Seconds 1}
Write-Verbose "$nodeName is now online. Proceeding to the next step...." -Verbose

#After node restarts, remove the disks on that node from Storage Maintenance Mode by running the following cmdlet:

Start-sleep 10

Get-StorageFaultDomain -type StorageScaleUnit -CimSession $cluster.Name | Where-Object {$_.FriendlyName -eq "$NodeName"} | Disable-StorageMaintenanceMode -CimSession $cluster.Name

Resume-ClusterNode -Cluster $cluster.Name -Name $NodeName -Failback Immediate

Get-StorageJob -CimSession $NodeName

Invoke-Command -ComputerName $NodeName -ScriptBlock {
    $vdisks = Get-VirtualDisk *
    foreach ($vdisk in $vdisks) {
    [string]$vdiskName = $vdisk.friendlyName
    Write-host "Volume $vdiskName" -ForegroundColor Yellow
    $extents = $vdisk | Get-PhysicalExtent | where virtualdiskUniqueId -eq $vdisk.UniqueId
	write-host "-> OperationalStatus" -foregroundcolor Yellow
    $extents | group -Property OperationalStatus -NoElement
    write-host ""
	write-host "-> CopyNumber" -foregroundcolor Yellow
	$Extents | Group CopyNumber -NoElement
	write-host ""
	write-host "-> Size" -foregroundcolor Yellow
	$Extents | Group Size -NoElement
	write-host ""
	
    }
}

