#https://docs.microsoft.com/en-us/windows-server/storage/storage-spaces/understand-storage-resync#how-to-monitor-storage-resync-in-windows-server-2019

Get-ClusterNode | Get-ClusterPerf -ClusterNodeSeriesName ClusterNode.Storage.Degraded 