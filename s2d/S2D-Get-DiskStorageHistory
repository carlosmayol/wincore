Get-PhysicalDisk | where-object {$_.CannotPoolReason -eq "In a Pool"} | Get-StorageHistory -NumberOfHours 168 #Last 7 days.
#Only returns local disks, fails on remote disks
#Tried to use StorageSNV, but I cannot correlate the storage nodes with the right pool (duplicate instance for local node (primordial pool & S2D))