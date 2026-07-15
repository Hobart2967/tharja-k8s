param(
    [string]$Name
)

$externalSwitch = Get-VMSwitch | Where-Object SwitchType -eq "External" | Select Name -First 1
$externalName = if ($externalSwitch) { $externalSwitch.Name } else { $null }

if (-not $externalSwitch) {
    Write-Host "No external switch found."
    Write-Host "Checking for Connected Adapters..."
    $adapter = Get-NetAdapter -Physical -ErrorAction SilentlyContinue |
        Where-Object { $_.Status -eq "Up" } |
        Select-Object -First 1

    if (-not $adapter) {
        $adapter = Get-NetAdapter -ErrorAction SilentlyContinue |
            Where-Object {
                $_.Status -eq "Up" -and
                $_.Name -notmatch "vEthernet|Loopback|Virtual"
            } |
            Select-Object -First 1
    }

    if (-not $adapter) {
        throw "No suitable UP network adapter found for creating an External VMSwitch."
    }

    $adapterName = $adapter.Name
    $uuid = [guid]::NewGuid().ToString()
    $externalName = "External-$uuid"
    Write-Host "Found Adapter: $adapterName, creating external switch $externalName ..."

    try {
        New-VMSwitch -Name $externalName -NetAdapterName $adapterName -AllowManagementOS $true -ErrorAction Stop
    }
    catch {
        $upAdapters = Get-NetAdapter -ErrorAction SilentlyContinue |
            Where-Object { $_.Status -eq "Up" } |
            Select-Object -ExpandProperty Name

        throw "Failed to create External VMSwitch using adapter '$adapterName'. Available UP adapters: $($upAdapters -join ', '). Original error: $($_.Exception.Message)"
    }
}

#Stop-VM $Name -TurnOff
#Remove-VM $Name
write-host "Creating VM: $Name"
New-VM -Name $Name `
    -Generation 2 `
    -MemoryStartupBytes 16GB `
    -NewVHDPath "C:\VMs\$Name.vhdx" `
    -NewVHDSizeBytes 1024GB

write-host "Setting VM Processor Count to 8"
Set-VMProcessor $Name -Count 8

write-host "Adding DVD Drives to VM: $Name"
Add-VMDvdDrive -VMName $Name `
    -Path "C:\VMs\ISOs\ubuntu-25.10-live-server-amd64.iso"

Add-VMDvdDrive -VMName $Name `
    -Path "C:\VMs\ISOs\seed-$Name.iso"

$dvd = Get-VMDvdDrive -VMName $Name | Select-Object -First 1

$hdd = Get-VMHardDiskDrive -VMName $Name | Select-Object -First 1

write-host "Setting VM Firmware for Secure Boot and Boot Order"
Set-VMFirmware `
    -VMName $Name `
    -SecureBootTemplate MicrosoftUEFICertificateAuthority `
    -BootOrder $dvd, $hdd

Get-VMFirmware -VMName $Name | Select-Object -Property BootOrder, SecureBootTemplate | Format-List

write-host "Connecting VM Network Adapter to $externalName"
Connect-VMNetworkAdapter `
    -VMName $Name `
    -SwitchName $externalName

write-host "Starting VM: $Name"
Start-VM $Name

write-host "Press any key to continue..."
[void][System.Console]::ReadKey($true)