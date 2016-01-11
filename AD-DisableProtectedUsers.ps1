# Date, Userinfo, and some external information before we start the process.

Import-Module ActiveDirectory
$date = get-date -format "d MMM yyyy"
$scriptpath = '{0}\scripts' -f $env:SystemDrive
$filepath = '{0}\scripts\Logs\terms.log' -f $env:SystemDrive
$terms = '{0}\scripts\terms.txt' -f $env:SystemDrive
$usr = $env:USERNAME
$users = get-content "$terms"

## Global Variables
# Get the current month, add value, combine to find deletion date OU
$disdate = get-date -f "MMM"
$deldate = (get-date).addmonths(2).tostring('MMM')
$comdate = "$disdate-$deldate"
# Disabled User destination - Requires Distinguished name
$DisUsr = "OU=$comdate,OU=Disabled,OU=Accounts,DC=stage,DC=contoso,DC=local"
# Comment this if you don't have a deny local logon group.
# $DenyLocLog = "DenyLogonGroup"

## SMTP Relay Server 
$mailserver = "relayhost.domain.tld"
$recAddres = "address@domain.tld"
$destAddress = "address@domain.tld"
$emailbody = "Account Disabled by $usr on $date Disabled in $disdate to be deleted in $deldate"

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
    write-output "New Password Generated"
    $ou = (Get-ADuser $aduser -Properties canonicalname).canonicalname
    Set-ADAccountPassword $aduser.name -NewPassword (ConvertTo-SecureString -AsPlainText "$password" -force)
    write-output "New Password applied to account."
    Set-ADuser $aduser -Description ("Disabled on $date by $usr // $ou")
    write-output "Description appended"
    $aduser | disable-adaccount
    write-output "Account disabled"
    $aduser | move-adobject -targetpath "$disusr"
    write-output "Account moved to $disusr."
    # Comment the next line if you don't have a deny local logon group
    # add-adgroupmember $DenyLocLog $aduser
    # write-output "Disabled Account group membership updated."
    # Logging and Email Confirmation
    write-host ("$emailbody")
    ("$emailbody") | Out-File -FilePath $filepath -force -append -width 200
    send-mailmessage -to "$Recaddress" -from "$destaddress" -subject "$user Disable Account Confirmation" -Body "$emailbody" -smtpserver $mailserver
}

Rename-Item -path $terms -NewName terms_$date.log
write-output "Terms.txt renamed to terms_$date.log"
new-item -path $scriptpath -name terms.txt -ItemType "file" -value "Remove this line of text. `r`nList accounts for termination line by line."
write-output "New terms.txt created."