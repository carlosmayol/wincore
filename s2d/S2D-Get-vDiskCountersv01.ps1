<#
#get-counter -ListSet  "Storage Spaces Virtual Disk*" | select -ExpandProperty Paths

#get-counter -ListSet "Storage Spaces Virtual Disk(*)\Virtual Disk Repair"

1..6 | %{

[string]$pathStatus = "\Storage Spaces Virtual Disk(*)\Virtual Disk Repair Phase $_ status"
[string]$pathcount = "\Storage Spaces Virtual Disk(*)\Virtual Disk Repair Phase $_ Count"

#get-counter $pathStatus
#get-counter $pathcount

$vdisksrepairstatus = get-counter $pathStatus 
$vdisksrepaircount = get-counter $pathcount 


#$vdisksrepairstatus.CounterSamples | fl -Property *
$status = $vdisksrepairstatus.CounterSamples[-1] | Select-Object Path, InstanceName, CookedValue, Timestamp 
# $status += $vdisksrepairstatus.CounterSamples[-1] | Select-Object Path, InstanceName, CookedValue, Timestamp # Not allowed

#$vdisksrepaircount.CounterSamples | fl -Property *
$count = $vdisksrepaircount.CounterSamples[-1] | Select-Object Path, InstanceName, CookedValue, Timestamp 
# $count += $vdisksrepaircount.CounterSamples[-1] | Select-Object Path, InstanceName, CookedValue, Timestamp # Not allowed

}

# Display collection to screen

$status | ft `
            @{N="ComputerName";E={$vdisksrepairstatus.CounterSamples.path[0].Split("\\")[2]}}, `
            @{N="Path";E={Split-Path $vdisksrepairstatus.CounterSamples.path[0] -Leaf}}, `
            InstanceName, CookedValue, Timestamp -AutoSize

$count | ft `
            @{N="ComputerName";E={$vdisksrepaircount.CounterSamples.path[0].Split("\\")[2]}}, `
            @{N="Path";E={Split-Path $vdisksrepaircount.CounterSamples.path[0] -Leaf}}, `
            InstanceName, CookedValue, Timestamp -AutoSize

# Works but screen output look ugly

#>

<#

#Cleaning variables
$counterspath = $null
$result = $null

#Defining arrays
$result = @()
$counterspath = (get-counter -ListSet  "Storage Spaces Virtual Disk*").paths  | ? {$_ -match "Repair"}

foreach ($path in $counterspath) {

$counter = Get-Counter -Counter $path
$data = $counter.CounterSamples | Select-Object Path, InstanceName, CookedValue, Timestamp 

$h = New-Object System.Object
$h | Add-Member -Type NoteProperty -name "ComputerName" -Value $data.path.split("\\")[2]
$h | Add-Member -Type NoteProperty -name "Path" -Value $data.path.split("\\")[4]
$h | Add-Member -type NoteProperty -name "InstanceName" -value $data.InstanceName
$h | Add-Member -type NoteProperty -name "CookedValue" -value $data.CookedValue
$h | Add-Member -type NoteProperty -name "Timestamp" -value $data.Timestamp

$result += $h

$Result | ft  ComputerName, path,  CookedValue, Timestamp -GroupBy InstanceName -AutoSize

}

#>