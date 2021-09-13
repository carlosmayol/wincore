# Fill in these variables with your values
$ServerList = "Cluster2016-2", "Cluster2016-3", "Cluster2016-4", "Cluster2016-1"

Invoke-Command ($ServerList) {remove-windowsfeature Failover-Clustering; restart-computer -force}