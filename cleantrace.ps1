##Define Item Age##
$limit = (Get-Date).AddMinutes(-30)

## List the items in the temp directory
Get-ChildItem -Path C:\Windows\Temp -filter *.keystonetrace -Force | Where-Object {$_.CreationTime -lt $limit} | Out-File C:\Logs\traceclean.log -Append| Remove-Item -Force
