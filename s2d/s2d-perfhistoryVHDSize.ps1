#
#Requires -module FailoverClusters
#Requires -module Hyper-V


    param(
        [Parameter(Mandatory)]
        [ValidateSet('LastDay','LastWeek', 'LastMonth', 'LastYear')]
        [string]$Timeframe,
        [switch]$ExportCSV
    )



#Collecting Clusters in the domain
$cluster = get-cluster -Domain $env:USERDOMAIN | Select-Object Name | Out-GridView -Title "Select your Cluster" -OutputMode Single

#Using britanica to look in the VMs
$vms =  (Get-CimInstance -CimSession $cluster.name -Namespace root\SDDC\Management -className SDDC_VirtualMachine).Name | Out-GridView -Title "Select your VMs" -PassThru
#$vhds = $vhds -join "`n"


#Create a new PSSession
$session = New-PSSession -ComputerName $cluster.Name

Invoke-Command -Session $session -ArgumentList @($vms)  -ScriptBlock {


Function Format-Bytes {
    Param (
        $RawValue
    )
    $i = 0 ; $Labels = ("B", "KB", "MB", "GB", "TB", "PB", "EB", "ZB", "YB")
    Do { $RawValue /= 1024 ; $i++ } While ( $RawValue -Gt 1024 )
    # Return
    [String][Math]::Round($RawValue) + " " + $Labels[$i]
}

$h = @()
$result = @()

 foreach ($vm in $args) {
    
    #Looking for VHDX paths for selected VMs. dynamic filter (vhdtype = 3) is optional here. Fixed size can increase in size too -> manually/admin
    $vhdssddc =  Get-CimInstance -Namespace root\SDDC\Management -className SDDC_VirtualMachine | Where-Object {($_.name -eq "$vm")} | select Vhds -ExpandProperty vhds
    $vhds = $vhdssddc.FilePath

    foreach ($vhd in $vhds) {

        $data = get-vhd $vhd | Get-ClusterPerf -VHDSeriesName VHD.Size.Current -TimeFrame $using:timeframe
        
        if ($data -ne $null ) { # Sometimes VHDX are new in britanica but does not cointain perf data yet
            $FirstSize = Format-Bytes ($data[0].Value)
            $LastSize = Format-Bytes ($data[-1].Value)
            $DiffSize = Format-Bytes (($data[-1].Value) - ($data[0].Value))
         
            $h = New-Object System.Object
            $h | Add-Member -Type NoteProperty -name "VM" -Value $vm
            $h | Add-Member -Type NoteProperty -name "VHDX" -Value $data[0].ObjectDescription
            #$h | Add-Member -type NoteProperty -name "FirstSize" -value $data[0].Value
            $h | Add-Member -type NoteProperty -name "FirstSize" -value $FirstSize
            $h | Add-Member -type NoteProperty -name "FirstTime" -value $data[0].Time
            #$h | Add-Member -type NoteProperty -name "LastSize" -value $data[-1].Value
            $h | Add-Member -type NoteProperty -name "LastSize" -value $LastSize
            $h | Add-Member -type NoteProperty -name "LastTime" -value $data[-1].Time
            $h | Add-Member -type NoteProperty -name "Difference" -value $DiffSize

            #Printing to screen
            $h | ft Vm,  VHDX, FirstTime, FirstSize, Lasttime, LastSize, Difference
        
            #Adding to result variable to export as CSV in remote system
            $result += $h
            }
       }

    }   

}

#Collection of results to the local system
if ($ExportCSV) {
$filesresult = Invoke-Command -session $session -ScriptBlock {$result}
Write-Host "Exporting result to $pwd\vhdx.csv" -ForegroundColor Green
$filesresult | Where-Object {$_} | Export-Csv -Path .\vhdx.csv -NoTypeInformation}

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