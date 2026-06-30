param(
    [string]$Name
)

#Stop-VM $Name -TurnOff
#Remove-VM $Name
New-VM -Name $Name `
    -Generation 2 `
    -MemoryStartupBytes 16GB `
    -NewVHDPath "C:\VMs\$Name.vhdx" `
    -NewVHDSizeBytes 1024GB

$dvd = Get-VMDvdDrive -VMName $Name | Select-Object -First 1
Set-VMFirmware `
    -VMName $Name `
    -SecureBootTemplate MicrosoftUEFICertificateAuthority
    -FirstBootDevice $dvd

Set-VMProcessor $Name -Count 8

Add-VMDvdDrive -VMName $Name `
    -Path "C:\VMs\ISOs\ubuntu-25.10-live-server-amd64.iso"

Add-VMDvdDrive -VMName $Name `
    -Path "C:\VMs\ISOs\seed.iso"

Connect-VMNetworkAdapter `
    -VMName $Name `
    -SwitchName "Default Switch"

Start-VM $Name

write-host "Press any key to continue..."
[void][System.Console]::ReadKey($true)