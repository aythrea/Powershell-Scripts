Import-Module ActiveDirectory
# Date, Userinfo, and some external information before we start the process.
# Standard Details
$date = get-date -format "d MMM yyyy"
$usr = (Get-ADUser $usr).name
$filepath = '{0}\Logs\terms.log' -f $env:SystemDrive
$usr = $env:USERNAME

# Disabled Date
$disdate = get-date -f "MMM"
# Deletion Date - Change the numeral in .addmonths to change the duration.
$deldate = (get-date).addmonths(2).tostring('MMM')
# Combined Dates to be used for OU placement
$comdate = "$disdate-$deldate"
# Disabled User destination - Requires Distinguished name
$DisUsr = "OU=$comdate,OU=Disabled,OU=Accounts,DC=Contoso,DC=com"

# Calls the list of users to be disabled. 
$users = get-content "C:\terms.txt" 
# Cycle through each line.
Foreach ($user in $users){
$user
$aduser = Get-ADuser $user
# For loop to find and remove the Accidental Deletion settings from each object stored in $aduser. - Provided by David Copeland
    $acls = get-acl -path ad:$aduser
            foreach ($acl in $acls.access) {
                if ($acl.IdentityReference -eq "Everyone" -and $acl.AccessControlType -eq "Deny") {
                    write-output "Prevent accidental deletion enabled"
                    write-output "Prevent accidental deletion being removed"`r`n
                    $acls.removeaccessrule($acl) | out-null
                    set-acl -path ad:$aduser -aclobject $acls | out-null                                   
                 }
             }    
    # Housekeeping tasks
    $ou = (Get-ADuser $aduser -Properties canonicalname).canonicalname
    Set-ADuser $aduser -Description ("Disabled on $date by $usr // $ou")
    $aduser | disable-adaccount
    $aduser | move-adobject -targetpath "$disusr"
    write-host ("Account Disabled by $usr" + " on $date" + " Disabled in $disdate" + " to be deleted in $deldate")
    ("Account Disabled by $usr" + " on $date" + " Disabled in $disdate" + " to be deleted in $deldate") | Out-File -FilePath $filepath -force -append -width 200
    }
}