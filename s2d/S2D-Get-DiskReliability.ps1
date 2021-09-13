# Works for 2012R2 in advance, does not use CLuter PErf History
Get-PhysicalDisk | ? { $_.MediaType -eq 'HDD' } | Get-StorageReliabilityCounter | Sort-Object WriteLatencyMax -Descending | ft DeviceID, ReadLatencyMax, WriteLatencyMax, PowerOnHours, ManufactureDate, ReadErrorsCorrected, ReadErrorsUncorrected, WriteErrorsCorrected, WriteErrorsUncorrected -AutoSize
Get-PhysicalDisk | ? { $_.MediaType -eq 'SSD' } | Get-StorageReliabilityCounter | Sort-Object WriteLatencyMax -Descending | ft DeviceID, ReadLatencyMax, WriteLatencyMax, PowerOnHours, ManufactureDate, ReadErrorsCorrected, ReadErrorsUncorrected, WriteErrorsCorrected, WriteErrorsUncorrected -AutoSize