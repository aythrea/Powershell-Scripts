Import-Module ActiveDirectory
$date = get-date -format "d MMM yyyy"
$usr = $env:USERNAME
$usr = (Get-ADUser $usr).name
$filepath = '{0}\Logs\disabledcomputers.txt' -f $env:SystemDrive
#new-psdrive -name addc4 -PSProvider ActiveDirectory -Server dc4-ad4 -Root //rootdse/

$computers = get-content "C:\disabled computer.txt" 

Foreach ($computer in $computers){
    $computer
    $adcomputer = Get-ADComputer $computer
    $acls = get-acl -path ad:$adcomputer
            foreach ($acl in $acls.access) {
                if ($acl.IdentityReference -eq "Everyone" -and $acl.AccessControlType -eq "Deny") {
                    write-output "Prevent accidental deletion enabled"
                    write-output "Prevent accidental deletion being removed"`r`n
                    $acls.removeaccessrule($acl) | out-null
                    set-acl -path ad:$adcomputer -aclobject $acls | out-null                                   
                 }

             }
    $ou = (Get-ADComputer $adcomputer -Properties canonicalname).canonicalname
    Set-ADComputer $adComputer -Description ("Disabled on $date by $usr // $ou")
    $adcomputer | disable-adaccount
    $adcomputer | move-adobject -targetpath "OU Distinguished name"
    write-host ("$date - " + "$Computer " + "in " + "$ou " +" has been disabled by $usr")
    ("$date - " + "$Computer " + "in " + "$ou " +" was disabled by $usr") | Out-File -FilePath $filepath -append -width 200
    }