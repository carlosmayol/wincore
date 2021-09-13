New-Volume -FriendlyName "Volume01" -FileSystem CSVFS_ReFS -StoragePoolFriendlyName s2d* -Size 1TB

#Hybrid in 2016 tiers
New-Volume -FriendlyName "CSV-Perf" -FileSystem CSVFS_ReFS -StoragePoolFriendlyName S2D* -StorageTierFriendlyNames Performance -StorageTierSizes 100GB
New-Volume -FriendlyName "CSV-Cap" -FileSystem CSVFS_ReFS -StoragePoolFriendlyName S2D* -StorageTierFriendlyNames Capacity -StorageTierSizes 100GB

#More on Tiers:
#https://github.com/Microsoft/WSLab/tree/master/Scenarios/S2D%20and%20Volumes%20deep%20dive