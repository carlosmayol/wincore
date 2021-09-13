$ClusterName="ClusterHCI"

$Nodes =  Get-StorageSubSystem Cluster* -CimSession ClusterHCI | Get-StorageNode | select -ExpandProperty Name

Foreach ($Node in $Nodes) {Get-StorageNode -Name $Node | Get-PhysicalDisk -PhysicallyConnected | Sort-Object -Property DeviceID}
