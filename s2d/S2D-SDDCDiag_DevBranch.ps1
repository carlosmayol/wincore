#https://docs.microsoft.com/en-us/windows-server/storage/storage-spaces/data-collection

[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
$module = 'PrivateCloud.DiagnosticInfo'; $branch = 'dev'
Invoke-WebRequest -Uri https://github.com/PowerShell/$module/archive/$branch.zip -OutFile $env:TEMP\$branch.zip
Expand-Archive -Path $env:TEMP\$branch.zip -DestinationPath $env:TEMP -Force
if (Test-Path $env:SystemRoot\System32\WindowsPowerShell\v1.0\Modules\$module) {
       rm -Recurse $env:SystemRoot\System32\WindowsPowerShell\v1.0\Modules\$module -ErrorAction Stop
       Remove-Module $module -ErrorAction SilentlyContinue
} else {
       Import-Module $module -ErrorAction SilentlyContinue
} 
if (-not ($m = Get-Module $module -ErrorAction SilentlyContinue)) {
       $md = "$env:ProgramFiles\WindowsPowerShell\Modules"
} else {
       $md = (gi $m.ModuleBase -ErrorAction SilentlyContinue).PsParentPath
       Remove-Module $module -ErrorAction SilentlyContinue
       rm -Recurse $m.ModuleBase -ErrorAction Stop
}
cp -Recurse $env:TEMP\$module-$branch\$module $md -Force -ErrorAction Stop
rm -Recurse $env:TEMP\$module-$branch,$env:TEMP\$branch.zip
Import-Module $module -Force  
