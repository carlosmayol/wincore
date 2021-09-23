$h = $null
$h = @()
$result = $null
$result = @()


#local execution required
$srvs= (Get-ClusterNode).name 

$paths = foreach ($srv in $srvs) {(get-vm -CimSession $srv).HardDrives.Path}


foreach ($path in $paths) { 

$data = get-vhd $path | Get-ClusterPerf -VHDSeriesName VHD.Size.Current -TimeFrame LastMonth

[string]$VHDX=  $data[0].ObjectDescription
[string]$FirstSize =$data[0].Value
[string]$LastSize = $data[-1].Value
[string]$time1 = $data[0].Time
[string]$time2 = $data[-1].Time
   
$h = New-Object System.Object
$h | Add-Member -Type NoteProperty -name "VHDX" -Value $data[0].ObjectDescription
$h | Add-Member -type NoteProperty -name "FirstSize" -value $FirstSize
$h | Add-Member -type NoteProperty -name "FirstTime" -value $time1
$h | Add-Member -type NoteProperty -name "LastSize" -value $LastSize
$h | Add-Member -type NoteProperty -name "LastTime" -value $time2

$result += $h

}


$h | ft VHDX, FirstTime, @{N="FirstSize";E={$h.FirstSize/1GB}}, Lasttime, @{N="LastSize";E={$h.LastSize/1GB}}

$result  | export-csv -Path vhdx.csv -NoTypeInformationath