## .\copy_templates.ps1 -app <3charappcode> -deployment_id <character id> -region <aws region 'US-EAST-1'>
## Version 1.1
## Date: 27Aug2018
## Chamren Beavers 

Param(
  [Parameter(Mandatory=$True)]
    [string]$app,
  
  [Parameter(Mandatory=$True)]
    [string]$deployment_id,

  [Parameter(Mandatory=$True)]
    [string]$region
  )

Write-Host This will produce template files for $app in $deployment_id in $region -BackgroundColor black -ForegroundColor Yellow

New-Item -ItemType Directory -Path .\templates/$app/macros
copy-item .\templates/app/*.j2 .\templates/$app/
copy-item .\templates/app/macros/*.j2 .\templates/$app/macros/ -Force

New-Item -ItemType Directory -path .\templates/$app/alert_defaults/globals
New-Item -ItemType Directory -Path .\substitutions/$app -Force
New-Item -ItemType Directory -Path .\outputs/$app -force

$glbl_alert_archive_path = ".\templates\app\alert_defaults"
$glbl_alert_dest_path = ".\templates\$app\alert_defaults"
$glbl_alert_archive = Get-childitem "$glbl_alert_archive_path"
$glbl_alert_dest = Get-childitem "$glbl_alert_dest_path"
#creates a touch file so the compare doesn't NULL out on first run
if (!(test-path $glbl_alert_dest_path\globals\touch.txt)){ new-item -ItemType File $glbl_alert_dest_path\globals\touch.txt -force}
#global
Compare-Object $glbl_alert_archive\globals $glbl_alert_dest\globals -Property Name, Length | Where-Object {$_.SideIndicator -eq "<="} | ForEach-Object { 
    Write-Host Copying "$glbl_alert_archive_path\globals\$($_.name)" to $glbl_alert_dest_path\globals; Copy-Item "$glbl_alert_archive_path\globals\$($_.name)" -Destination $glbl_alert_dest_path\globals -Force; }

#region
if (!(test-path $glbl_alert_dest_path\regiondefaults\touch.txt)){ new-item -ItemType File $glbl_alert_dest_path\regiondefaults\touch.txt -force}
Compare-Object $glbl_alert_archive\regiondefaults $glbl_alert_dest\regiondefaults -Property Name, Length | Where-Object {$_.SideIndicator -eq "<="} | ForEach-Object { 
    Write-Host Copying "$glbl_alert_archive_path\regiondefaults\$($_.name)" to $glbl_alert_dest_path\regiondefaults; Copy-Item "$glbl_alert_archive_path\regiondefaults\$($_.name)" -Destination $glbl_alert_dest_path\regiondefaults -Force; }

#deployment id
if (!(test-path $glbl_alert_dest_path\stackdefaults\touch.txt)){ new-item -ItemType File $glbl_alert_dest_path\stackdefaults\touch.txt -force}
Compare-Object $glbl_alert_archive\stackdefaults $glbl_alert_dest\stackdefaults -Property Name, Length | Where-Object {$_.SideIndicator -eq "<="} | ForEach-Object { 
    Write-Host Copying "$glbl_alert_archive_path\stackdefaults\$($_.name)" to $glbl_alert_dest_path\stackdefaults; Copy-Item "$glbl_alert_archive_path\stackdefaults\$($_.name)" -Destination $glbl_alert_dest_path\stackdefaults -Force; }

#alert resources
if (!(test-path $glbl_alert_dest_path\alert_resources\touch.txt)){ new-item -ItemType File $glbl_alert_dest_path\alert_resources\touch.txt -force}
Compare-Object $glbl_alert_archive\alert_resources $glbl_alert_dest\alert_resources -Property Name, Length | Where-Object {$_.SideIndicator -eq "<="} | ForEach-Object { 
    Write-Host Copying "$glbl_alert_archive_path\alert_resources\$($_.name)" to $glbl_alert_dest_path\alert_resources; Copy-Item "$glbl_alert_archive_path\alert_resources\$($_.name)" -Destination $glbl_alert_dest_path\alert_resources -Force; }


