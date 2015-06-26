##Pre-requisites: Requires modules Activedirectory and AWSPowershell

import-module Activedirectory
import-module awspowershell

## Create User Account from CSV Resource
#get list of fullnames

## Global Variables
#CSV import here-ish.
$fullnames = "Brian Brown"
$path = 'cn'

## Use the full name to populate the account properties.
#split fullnames into first name and last name
foreach($displayName in $fullnames) {
    $split = $displayname.split( )
    $givenname = $split[0]
    $surname = $split[1]
    $firstinit = $firstname.substring(0,1)
    
    New-ADUser -SamAccountName "glenjohn" -GivenName "$givenname" -Surname "$surname" -DisplayName "$displayname" -Path $path -OtherAttributes-CannotChangePassword $false
    #Add User to Foundational Groups
    
    
}