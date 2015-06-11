#Load the directory listed at $computers with a line by line of the computers to be disabled.
#Ensure there isn't a line at the end of the file. 

Import-Module ActiveDirectory
# Date, Userinfo, and some external information before we start the process.

$date = get-date -format "d MMM yyyy"
$usr = $env:USERNAME
$usr = (Get-ADUser $usr).name
$filepath = '{0}\Logs\disabledcomputers.txt' -f $env:SystemDrive

# Calls the list of computers to be disabled. 
$computers = get-content "C:\disabled computer.txt" 

# Cycle through each line.
Foreach ($computer in $computers){
    $computer
    
    # Retrieve the adcomputer object for each line of text in $computer. Store in $adcomputer.
    $adcomputer = Get-ADComputer $computer
    
    # For loop to find and remove the Accidental Deletion settings from each object stored in $adcomputer. - Provided by David Copeland
    $acls = get-acl -path ad:$adcomputer
            foreach ($acl in $acls.access) {
                if ($acl.IdentityReference -eq "Everyone" -and $acl.AccessControlType -eq "Deny") {
                    write-output "Prevent accidental deletion enabled"
                    write-output "Prevent accidental deletion being removed"`r`n
                    $acls.removeaccessrule($acl) | out-null
                    set-acl -path ad:$adcomputer -aclobject $acls | out-null                                   
                 }

             }
    
    # Housekeeping tasks
    $ou = (Get-ADComputer $adcomputer -Properties canonicalname).canonicalname
    Set-ADComputer $adComputer -Description ("Disabled on $date by $usr // $ou")
    $adcomputer | disable-adaccount
    $adcomputer | move-adobject -targetpath "OU location by Distinguished Name"
    write-host ("$date - " + "$Computer " + "in " + "$ou " +"has been disabled by $usr")
    ("$date - " + "$Computer " + "in " + "$ou " +"was disabled by $usr") | Out-File -FilePath $filepath -force -append -width 200
    }