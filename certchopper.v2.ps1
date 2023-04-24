#First half of a two part script. This half takes a stack of pfx files and breaks them down into their parts for later upload to ACM. 

$env:path = $env:path + ";C:\Program Files\OpenSSL\bin\openssl.exe"
Set-Location "C:\flats\missing certs"
$CertPassword = 'password'
$certpath = Get-ChildItem .
$openssl = 'C:\Program Files\OpenSSL-Win64\bin\openssl.exe'
$ErrorActionPreference = 'SilentlyContinue'
foreach($sourcePFX in $certpath)
{
  if (test-path -Path "directory\$sourcePFX"){
    write-host "Path Exists!"}
    else {
      write-host "Path Does Not Exist"
      New-Item -path . -Name "directory\$sourcePFX" -ItemType Directory
         }
      #directories create as expected
      $PrivateKeyFile = ".\directory\$sourcePFX\key.pem"
      $PublicKeyFile = ".\directory\$sourcePFX\cert.pem"
      $DecryptedRSA = ".\directory\$sourcePFX\server.key"
              
      #We can extract the private key form a PFX to a PEM file with this command:
      & $openssl pkcs12 -in $sourcePFX -nocerts -out $PrivateKeyFile -password pass:$CertPassword -passout pass:$CertPassword
      #Exporting the certificate only:
      & $openssl pkcs12 -in $sourcePFX -clcerts -nokeys -out $PublicKeyFile -password pass:$CertPassword
      #decrypt the private key
      #Removing the password from the extracted private key:
      & $openssl rsa -in $PrivateKeyFile -out $DecryptedRSA -passin pass:$CertPassword -passout pass:$CertPassword
      }
