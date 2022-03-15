#Display Metadata Disks

Get-StoragePool | Get-PhysicalDisk -HasMetadata | Sort-Object Description |format-table DeviceId,FriendlyName,SerialNumber,MediaType,Description



#Display metadata disks per volume
Get-VirtualDisk 

$vdisks = Get-VirtualDisk 


foreach ($vdisk in $vdisks) {
write-host ""
Get-VirtualDisk -friendlyname $vdisk.friendlyName | Get-PhysicalDisk -HasMetadata | Sort-Object Description | Format-table DeviceId,FriendlyName,SerialNumber,MediaType,Description}
