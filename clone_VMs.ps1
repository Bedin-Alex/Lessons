<# Example VMS.txt
vm1,4096,2
vm2,8192,4
vm3,2048,1
#>
$vmBasePath = "E:\VM" # Path where VM will be created
$vhdxTemplate = "E:\VM\BACKUP_DISK\kubespray.vhdx" # Path to "Golden" image
$vmsFile = ".\VMS.txt" # Path to file with list of VMs
$vmSwitchName = "Ext" # Name of external network adapter

if (-not (Get-VMSwitch -Name $vmSwitchName -ErrorAction SilentlyContinue)) {
    Write-Error "Adapter '$vmSwitchName' wasn't found. Check the name of adapter and try again."
    exit 1
}

Get-Content $vmsFile | ForEach-Object {
    $line = $_.Trim()
    if ($line -eq "") { return }

    $parts = $line -split ","
    if ($parts.Count -ne 3) {
        Write-Warning "String isn't valid: $line"
        return
    }

    $vmName = $parts[0].Trim()
    $ramMB = [int]$parts[1].Trim()
    $cpuCount = [int]$parts[2].Trim()
    $vmPath = Join-Path $vmBasePath $vmName
    $vhdPath = Join-Path $vmPath "$vmName.vhdx"

    if (-not (Test-Path $vmPath)) {
        New-Item -ItemType Directory -Path $vmPath | Out-Null
    }

    Copy-Item $vhdxTemplate $vhdPath -Force

    Write-Host "Creating VM: $vmName ($ramMB MB RAM, $cpuCount CPU)"
    $memBytes = $ramMB * 1MB
    New-VM -Name $vmName `
           -MemoryStartupBytes $memBytes `
           -Generation 1 `
           -Path $vmPath `
           -VHDPath $vhdPath | Out-Null

    Set-VM -Name $vmName -AutomaticCheckpointsEnabled $false
    Set-VMProcessor -VMName $vmName -Count $cpuCount

    Connect-VMNetworkAdapter -VMName $vmName -Name "Network Adapter" -SwitchName "Ext"
    Write-Host "VM '$vmName' was created with external adapter '$vmSwitchName'." -ForegroundColor Green

}

Write-Host "Everything was created successfully! Congrats bro" -ForegroundColor Cyan
