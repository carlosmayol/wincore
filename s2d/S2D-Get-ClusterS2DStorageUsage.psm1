function Get-ClusterS2DStorageUsage {

  [CmdletBinding()]
  param
  (
      [Parameter(
      ValueFromPipeline=$True,
      ValueFromPipelineByPropertyName=$True,
        HelpMessage='- FriendlyName ')]
      [Alias('StoragePool')]
      [string[]]$FriendlyName,

      [string]$MediaType = 'all'	
  )

    begin 
    {
        $MediaType = $MediaType.ToUpper()

        Write-Verbose "Checking Cluster Nodes exists"
        $ClusterNodes = Get-ClusterNode
        if ($ClusterNodes) {
            $Msg = $ClusterNodes.Count.ToString() + " cluster nodes found"
            Write-Verbose $Msg
        } else {
            $Msg = "No cluster nodes found"
            Write-Error $Msg
            Return
        }

        if (! $FriendlyName) {
            Write-Verbose "No StoragePool name entered - Getting all Pools"
            $SP = Get-StoragePool | ? IsPrimordial -eq $False
            if ($SP) {
                $FriendlyName = $SP.FriendlyName
                $Msg = "Storage Pool found [" + $FriendlyName + "]"
                Write-Verbose $Msg
            } else {
                Write-Error "Error - No Storage Pools available"
            }
        }
        $Obj = @()  
    }

    Process 
    {
        foreach ($Pool in $FriendlyName) 
        {
            $Msg = "Processing " + $Pool
            Write-Verbose $Msg


            Write-Verbose "Checking StoragePool exists"
            $thisPool = Get-StoragePool -FriendlyName $Pool -ErrorAction Stop

            Write-Verbose "Checking for disks with the MediaType"
            if ( $MediaType -eq "all" )
            {
                $CapacityDisks = $thisPool | Get-PhysicalDisk | ? MediaType -ne "Journal"
            } else {
                $CapacityDisks = $thisPool | Get-PhysicalDisk | ? MediaType -eq $MediaType
            }
            if ($CapacityDisks) {
                $Msg = $CapacityDisks.Count.ToString() + " Disks with MediaType " + $MediaType + " found"
                Write-Verbose $Msg
            } else {
                $Msg = "No qualifying disks found with MediaType:" + $MediaType
                Write-Error $Msg
                Return
            }

            $PoolDiskCount = $CapacityDisks.Count
            $Msg = ("Number of Pool Disks: " + $PoolDiskCount)
            Write-Verbose $Msg
            $TotalSize = 0  
            $TotalAlloc = 0
 
            ForEach ($Disk in $CapacityDisks)
            { 

                $DiskSize = $Disk.Size /1GB
                $DiskAlloc = $Disk.AllocatedSize /1GB
                $FreeSpace = $DiskSize - $DiskAlloc
                $TotalSize += $DiskSize 
                $TotalAlloc += $DiskAlloc 

                $Msg =  "Disk Name: [" + $Disk.FriendlyName + "] ",
                    ("Size: {0:n2} GB  " -f ($DiskSize) ),
                    ("Alloc: {0:n2} GB  " -f ($DiskAlloc)),
                    ("Free Space: {0:n2} GB" -f ($FreeSpace)) 
                Write-Verbose $Msg 
           }


            $PoolFree = $TotalSize - $TotalAlloc
            $PercentFull = $TotalAlloc / $TotalSize * 100

            Write-Verbose " "
            Write-Verbose "-----------------------------------------------------"
            $Msg  = "Pool: " + $thisPool.FriendlyName
            Write-Verbose $Msg
            Write-Verbose " "
            $Msg =  ("Total Space: {0:n2} GB" -f ($TotalSize))
            Write-Verbose $Msg
            $Msg =  ("Total Alloc: {0:n2} GB" -f ($TotalAlloc))
            Write-Verbose $Msg
            $Msg =  ("Free Space: {0:n2} GB" -f ($PoolFree))
            Write-Verbose $Msg
            $Msg =  ("Percent Used: {0:n2}% GB" -f ($PercentFull))
            Write-Verbose $Msg

            $ReserveRequired = $TotalSize / $PoolDiskCount * 2

            $Properties = [Ordered]@{
                'Pool'=$thisPool.FriendlyName;
                'TotalCapacity'=$TotalSize;
                'TotalUsedSpace'=$TotalAlloc;
                'TotalFreeSpace'=$PoolFree;
                'PercentUsed'=$PercentFull
                'UnitOfMeasure'="GB";
                'DiskCount'=$PoolDiskCount;
                'SelectedMediaType'=$MediaType;
                'ReserveRequired'=$ReserveRequired;     
            }
            $Obj += New-Object -TypeName PSObject -Property $Properties
        }
        
        Write-Output $Obj
    }
}