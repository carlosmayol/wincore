
Get-storagesubsystem clus* | get-storagehealthsetting
Get-storagesubsystem clus* | get-storagehealthsetting -Name System.Storage.SupportedComponents.Document | fl *
Get-storagesubsystem clus* | get-storagehealthsetting -Name Platform.Rules.Document | fl *

