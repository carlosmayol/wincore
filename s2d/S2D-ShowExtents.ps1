
# ************************************************************************************** #
# List the Operational Status of the Extens, for all vDisks
# ************************************************************************************** #

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