Param(
    [Parameter(Mandatory=$true)]
    [ValidateSet('All','Repair')]  
    [String]
    $Collection,

    [Parameter(Mandatory=$true)]
    [String[]]
    $Servers="localhost" #Executes locally

)


#Requires -version 5

#Set Error Action to Silently Continue
$ErrorActionPreference = "SilentlyContinue"

#Script Version
$sScriptVersion = "1.0"

[regex]$rx = "(?<=\\\\).*(?=\\)"

if ($Collection -eq "All") {

    foreach ($server in $servers) {
	    write-host "Connecting to node $server ..." -ForegroundColor Green 
        if (Test-Connection $server -quiet -Count 2 -TimeToLive 15) {
            $counterspath = (get-counter -ComputerName $server -ListSet  "Storage Spaces Virtual Disk*").PathsWithInstances  | ? {$_ -notmatch "node"}
            $counters = Get-Counter -Counter $counterspath 
            if ($counters.CounterSamples.InstanceName -gt 0) {         
                $counters.CounterSamples | sort InstanceName,Path | Where-Object {$_.CookedValue -ne 0} | 
                format-table -GroupBy InstanceName -property @{Name="Counter";Expression={Split-path $_.path -Leaf}},
                Cookedvalue,timestamp,@{Name="ComputerName";Expression={$rx.Match((Split-Path $_.path)).value.ToUpper()}}
                }
            else {Write-Host " --> No instances on this node $server ...." -ForegroundColor "red" ; write-host}
            }

        else {Write-Host "Connection to"$server "does not work properly! go to next ...." -ForegroundColor "red"}
        }
    }

Else {
    
    foreach ($server in $servers) {
    	write-host "Connecting to node $server ..." -ForegroundColor Green 
        if (Test-Connection $server -quiet -Count 2 -TimeToLive 15) {
            $counterspath = (get-counter -ComputerName $server -ListSet  "Storage Spaces Virtual Disk*").PathsWithInstances | ? {($_ -match "Repair") -and ($_ -notmatch "node")}
            $counters = Get-Counter -Counter $counterspath
            if ($counters.CounterSamples.InstanceName -gt 0) {    
                    [regex]$rx = "(?<=\\\\).*(?=\\)"
                    $counters.CounterSamples | sort InstanceName,Path | Where-Object {$_.CookedValue -ne 0} | 
                    format-table -GroupBy InstanceName -property @{Name="Counter";Expression={Split-path $_.path -Leaf}},
                    Cookedvalue,timestamp,@{Name="ComputerName";Expression={$rx.Match((Split-Path $_.path)).value.ToUpper()}}
                    }
            else {Write-Host " --> No instances on this node $server ...." -ForegroundColor "red" ; write-host}
            }

        else {Write-Host "Connection to"$server "does not work properly! go to next ...." -ForegroundColor "red"}
        }
    }