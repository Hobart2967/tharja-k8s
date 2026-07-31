Import-Certificate `
  -FilePath C:\Windows\Temp\pebble-root-ca.crt `
  -CertStoreLocation Cert:\LocalMachine\Root

write-host "Press any key to continue..."
[void][System.Console]::ReadKey($true)