 Function Get-ClusterWriteCacheUsage {
    [cmdletbinding()]
    param(
        # Cluster's to query
        [string[]]$ClusterName="localhost",
        # Show only the total per node
        [switch]$TotalOnly
    )
    begin {
        # Establish helper functions
        Function Format-Bytes {
            Param (
                $RawValue
            )
            $i = 0 ; $Labels = ("B", "KB", "MB", "GB", "TB", "PB", "EB", "ZB", "YB")
            Do { if ( $RawValue -Gt 1024 ) { $RawValue /= 1024 ; $i++ } } While ( $RawValue -Gt 1024 )
            # Return
            [String][Math]::Round($RawValue,2) + " " + $Labels[$i]
        }
    }
    Process {
        # Start processing supplied cluster names
        Foreach ($Name in $ClusterName) {
            # Confirm the cluster exists
            try{
                $Cluster = (Get-Cluster -Name $Name -ErrorAction Stop).Name 
            }catch{
                throw "Cluster Name $Name supplied, can't be found"
            }
            # Query for Nodes
            $Nodes = (Get-ClusterNode -Cluster $Cluster)
            # Query for Cluster Cache Page Size
            [int64]$PageSize = (Get-ClusterS2D -CimSession $Cluster).CachePageSizeKBytes * 1KB
            # Loop through each node to get performance counters
            Foreach ($Node in $Nodes) {
                $NodeName = $Node.Name
                # Determine if we need all instances or just _total
                if ($TotalOnly -eq $true) {
                    $Query = "_Total"
                }
                else {
                    $Query = "*"
                }
                $DirtyCounter = "\\$NodeName\Cluster Storage Cache Stores($Query)\Cache Pages Dirty"
                $SizeCounter = "\\$NodeName\Cluster Storage Cache Stores($Query)\Cache Pages"
                # Collect the actual counter data
                $Data = (Get-Counter -Counter $DirtyCounter -ComputerName $NodeName).CounterSamples
                $Data += (Get-Counter -Counter $SizeCounter -ComputerName $NodeName).CounterSamples
                # Determine the names of the disks queried
                $Instances = ($Data | Sort-Object InstanceName).InstanceName | Get-Unique
                # Find matching data for each disk and return it formated
                Foreach ($Instance in $Instances) {
                    # get Matching Data
                    $CacheSize = (
                        $Data |Where-Object {
                            ($_.InstanceName -eq $Instance) -and 
                            ($_.Path -ilike "*\cache pages")
                        }
                        ).RawValue * $PageSize
                    $CacheUsage = (
                        $Data |Where-Object {
                            ($_.InstanceName -eq $Instance) -and 
                            ($_.Path -ilike "*\cache pages dirty")
                        }
                        ).RawValue * $PageSize
                    # Format data into a PS Object and return it
                    [pscustomobject][ordered]@{
                        ComputerName    = $NodeName
                        Instance        = $Instance
                        WriteCacheUsage = Format-Bytes -RawValue $CacheUsage
                        CacheSize       = Format-Bytes -RawValue $CacheSize
                    }
                }
            }
        }
    }
}