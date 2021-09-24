#
$cluster = get-cluster -Domain $env:USERDOMAIN | Select-Object Name | Out-GridView -Title "Select your Cluster" -OutputMode Single 

$srvs= (Get-ClusterNode -Cluster $cluster.name).name 

$paths = foreach ($srv in $srvs) {(get-vm -CimSession $srv).HardDrives.Path}

$paths = $paths | Select-Object  | Out-GridView -Title "Select your VHDX" -OutputMode Single 

$session = New-PSSession -ComputerName $cluster.Name -Authentication CredSsp -Credential (Get-Credential -Message "Enter CREDSSP Auth")

Invoke-Command -Session $session -ArgumentList @($paths) -ScriptBlock {


$h = $null
$h = @()
$result = $null
$result = @()


#local execution required
$srvs= (Get-ClusterNode).name 

$paths = foreach ($srv in $srvs) {(get-vm -CimSession $srv).HardDrives.Path} 


foreach ($path in $paths) { 
    
    if ($path -ne $null)   {
    
    $data = get-vhd $path | Get-ClusterPerf -VHDSeriesName VHD.Size.Current -TimeFrame LastMonth

    [string]$VHDX=  $data[0].ObjectDescription
    [string]$FirstSize =$data[0].Value
    [string]$LastSize = $data[-1].Value
    [string]$time1 = $data[0].Time
    [string]$time2 = $data[-1].Time
   
    $h = New-Object System.Object
    $h | Add-Member -Type NoteProperty -name "VHDX" -Value $VHDX
    $h | Add-Member -type NoteProperty -name "FirstSize" -value $FirstSize
    $h | Add-Member -type NoteProperty -name "FirstTime" -value $time1
    $h | Add-Member -type NoteProperty -name "LastSize" -value $LastSize
    $h | Add-Member -type NoteProperty -name "LastTime" -value $time2

    $result += $h

    }

}

$h | ft VHDX, FirstTime, @{N="FirstSize";E={"{0:F2}" -f ($h.FirstSize/1GB)}}, Lasttime, @{N="LastSize";E={"{0:F2}" -f ($h.LastSize/1GB)}}

}

#Collection the results of the previous commands to retreive the information to the local system
$filesresult = Invoke-Command -session $session -ScriptBlock {$result}
$filesresult | Where-Object {$_} | Export-Csv -Path .\vhdx.csv -NoTypeInformation
Remove-PSSession -Session $session


<#
#LOCAL NODE code (all vhdx of all nodes)

$h = $null
$h = @()
$result = $null
$result = @()


#local execution required
$srvs= (Get-ClusterNode).name 

$paths = foreach ($srv in $srvs) {(get-vm -CimSession $srv).HardDrives.Path} 


foreach ($path in $paths) { 
if ($path -ne $null) {$data = get-vhd $path | Get-ClusterPerf -VHDSeriesName VHD.Size.Current -TimeFrame LastMonth} 

[string]$VHDX=  $data[0].ObjectDescription
[string]$FirstSize =$data[0].Value
[string]$LastSize = $data[-1].Value
[string]$time1 = $data[0].Time
[string]$time2 = $data[-1].Time
   
$h = New-Object System.Object
$h | Add-Member -Type NoteProperty -name "VHDX" -Value $VHDX
$h | Add-Member -type NoteProperty -name "FirstSize" -value $FirstSize
$h | Add-Member -type NoteProperty -name "FirstTime" -value $time1
$h | Add-Member -type NoteProperty -name "LastSize" -value $LastSize
$h | Add-Member -type NoteProperty -name "LastTime" -value $time2

$result += $h

}


$h | ft VHDX, FirstTime, @{N="FirstSize";E={"{0:F2}" -f ($h.FirstSize/1GB)}}, Lasttime, @{N="LastSize";E={"{0:F2}" -f ($h.LastSize/1GB)}}

#$result  | export-csv -Path vhdx.csv -NoTypeInformation
#>