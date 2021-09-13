#requires -modules S2D-Get-ClusterS2DStorageUsage

$Pool = Get-StoragePool | ? {-not($_.IsPrimordial)} | select FriendlyName
$Usage = Get-ClusterS2DStorageUsage -StoragePool $Pool.FriendlyName
if ($Usage.ReserveRequired -gt $Usage.TotalFreeSpace) { Write-Host "Call Home for Help!" }

$Pool = Get-StoragePool | ? {-not($_.IsPrimordial)} | select FriendlyName
$Usage = Get-ClusterS2DStorageUsage -StoragePool $Pool.FriendlyName -MediaType All
$Usage
if ($Usage.ReserveRequired -gt $Usage.TotalFreeSpace)
   { Write-Host "Warning, capacity below requirement to rebuild!" -ForegroundColor Yellow}
elseif ($Usage.PercentUsed -gt “90”)
   { Write-Host "Warning, low on free space!" -ForegroundColor Yellow }
else {Write-Host "Informational, No space issues found!" -ForegroundColor Green}