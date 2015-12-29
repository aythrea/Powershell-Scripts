# Date, Userinfo, and some external information before we start the process.

Import-Module ActiveDirectory
$date = get-date -format "d MMM yyyy"
$usr = (Get-ADUser $usr).name
$filepath = '{0}\Logs\terms.log' -f $env:SystemDrive
$usr = $env:USERNAME
$users = get-content "C:\terms.txt"

## Global Variables
# Get the current month, add value, combine to find deletion date OU
$disdate = get-date -f "MMM"
$deldate = (get-date).addmonths(2).tostring('MMM')
$comdate = "$disdate-$deldate"
# Disabled User destination - Requires Distinguished name
$DisUsr = "OU=$comdate,OU=Disabled,OU=Accounts,DC=Contoso,DC=com"
# Comment this if you don't have a deny local logon group.
$DenyLocLog = "DenyLogonGroup"

## SMTP Relay Server 
$mailserver = "relayhost.domain.tld"
$recAddres = "address@domain.tld"
$destAddress = "address@domain.tld"

## The Action
# Calls the list of users to be disabled.
Foreach ($user in $users){
$user
$aduser = Get-ADuser $user
## For loop to find and remove the Accidental Deletion settings from each object stored in $aduser.
    $acls = get-acl -path ad:$aduser
            foreach ($acl in $acls.access) {
                if ($acl.IdentityReference -eq "Everyone" -and $acl.AccessControlType -eq "Deny") {
                    write-output "Prevent accidental deletion enabled"
                    write-output "Prevent accidental deletion being removed"`r`n
                    $acls.removeaccessrule($acl) | out-null
                    set-acl -path ad:$aduser -aclobject $acls | out-null                                   
                 }
             }    
    # Housekeeping tasks - Sequential: Generate and apply randomized password, Update account description move account to disabled ou, log changes
    $password = ([char[]](Get-Random -Input $(48..57 + 65..90 + 97..122) -Count 16)) -join ""
    $ou = (Get-ADuser $aduser -Properties canonicalname).canonicalname
    Set-ADAccountPassword $aduser.name -NewPassword (ConvertTo-SecureString -AsPlainText "$password" -force)
    Set-ADuser $aduser -Description ("Disabled on $date by $usr // $ou")
    $aduser | disable-adaccount
    $aduser | move-adobject -targetpath "$disusr"
    # Comment the next line if you don't have a deny local logon group
    add-adgroupmember $DenyLocLog $aduser
    # Logging and Email Confirmation
    write-host ("Account Disabled by $usr" + " on $date" + " Disabled in $disdate" + " to be deleted on $deldate")
    ("Account Disabled by $usr" + " on $date" + " Disabled in $disdate" + " to be deleted on $deldate") | Out-File -FilePath $filepath -force -append -width 200
    send-mailmessage -to "$recaddress" -from "$destaddress" -subject "Disable Account Confirmation" -Body "Account Disabled by $usr" + " on $date" + " Disabled in $disdate" + " to be deleted on $deldate" -smtpserver $mailserver
    }
}
