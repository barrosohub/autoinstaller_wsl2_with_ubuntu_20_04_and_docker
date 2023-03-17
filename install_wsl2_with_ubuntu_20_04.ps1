$OutputEncoding = [System.Text.Encoding]::UTF8

function Write-Info {
    param ([string]$Message)
    Write-Host $Message -ForegroundColor Cyan
}

# Check if WSL 2 is installed
$wsl2Feature = Get-WindowsOptionalFeature -Online -FeatureName "VirtualMachinePlatform"
if ($wsl2Feature.State -ne "Enabled") {
    try {
        Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Windows-Subsystem-Linux -NoRestart
        Enable-WindowsOptionalFeature -Online -FeatureName VirtualMachinePlatform -NoRestart
        Write-Info "Please restart your computer to finish installing WSL 2"
    } catch {
        Write-Host "WSL 2 could not be installed. Please make sure your computer supports virtualization and is running a compatible version of Windows." -ForegroundColor Red
        exit 1
    }
}
Write-Info "WSL2 is installed."

# Install Ubuntu 20.04 if it's not installed
$ubuntuInstalled = $false
try {
    $distros = (wsl.exe -l -q)
    foreach ($distro in $distros) {
        if ($distro -match "Ubuntu-20.04") {
            $ubuntuInstalled = $true
            break
        }
    }
} catch [System.Management.Automation.CommandNotFoundException] {
    Write-Host "WSL is not supported on the current system." -ForegroundColor Red
    exit 1
} catch {
    Write-Host "An error occurred while checking if Ubuntu 20.04 is installed in WSL 2." -ForegroundColor Red
    exit 1
}
if ($ubuntuInstalled) {
    Write-Info "Ubuntu 20.04 is already installed in WSL 2."
} else {
    try {
        Add-AppxPackage -Register -Path (Get-AppPackage -Name Microsoft.Ubuntu.20.04 | Select -ExpandProperty InstallLocation)\\appxmanifest.xml -DisableDevelopmentMode | Out-Null
        Write-Host "============================================"
        Write-Host "Ubuntu 20.04 installs have started!" -ForegroundColor Green
        Write-Host "============================================"
    } catch {
        Write-Host "Ubuntu 20.04 installation failed. Please install Ubuntu 20.04 from the Microsoft Store manually." -ForegroundColor Red
        exit 1
    }
}

Write-Host "============================================"
Write-Host "After restarting your computer, you can run Ubuntu 20.04 in WSL 2 by typing 'wsl' or 'ubuntu2004' in PowerShell or command prompt." -ForegroundColor Green
Write-Host "============================================"
Read-Host "Press Enter to exit"

