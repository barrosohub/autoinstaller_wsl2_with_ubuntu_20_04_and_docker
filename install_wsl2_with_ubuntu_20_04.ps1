$OutputEncoding = [System.Text.Encoding]::UTF8

function Write-Info {
    param ([string]$Message)
    Write-Host ""
    Write-Host $Message -ForegroundColor Cyan
}

function WaitForEscOrEnter {
    Write-Host ""
    Write-Host "   Pressione ESC ou ENTER para fechar a janela." -ForegroundColor Yellow
    Write-Host ""
    do {
        $key = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
    } until ($key.VirtualKeyCode -eq 27 -or $key.VirtualKeyCode -eq 13)
    exit
}

# Verificando se o Ubuntu 20.04 está instalado
$ubuntuInstalled = $false
try {
    $distros = (wsl.exe -l -q)
    foreach ($distro in $distros) {
        if ($distro -match "Ubuntu-20.04") {
            $ubuntuInstalled = $true
            break
        }
    }
} catch { }

Write-Info "Verificando o status do WSL... Aguarde, pode demorar alguns minutos."
$wslFeature = Get-WindowsOptionalFeature -Online -FeatureName "Microsoft-Windows-Subsystem-Linux"
if ($wslFeature.State -eq "Enabled") {
    Write-Info "WSL2 está instalado."

    if ($ubuntuInstalled) {
        Write-Info "Notamos que você já tem o WSL rodando normal, e que o Ubuntu 20.04 está instalado corretamente no WSL."
    } else {
        Write-Host "============================================"
        Write-Info "Iniciando a instalacao do Ubuntu 20.04 no WSL2..."
        Write-Host "============================================"
        try {
            wsl.exe --install -d Ubuntu-20.04
            Start-Sleep -Seconds 30
            wsl.exe --set-version Ubuntu-20.04 2
        } catch {
            Write-Host "Nao foi possivel instalar o Ubuntu 20.04 usando 'wsl --install -d Ubuntu-20.04'. Tentando outra abordagem..." -ForegroundColor Yellow
            $UbuntuUrl = "https://aka.ms/wslubuntu2004"
            $DownloadPath = "$env:TEMP\Ubuntu_2004.appx"
            Invoke-WebRequest -Uri $UbuntuUrl -OutFile $DownloadPath
            Add-AppxPackage -Path $DownloadPath
        }
        Write-Host "============================================"
        Write-Host "Ubuntu 20.04 instalado com sucesso!" -ForegroundColor Green
        Write-Host "============================================"
    }
} else {
    Write-Info "Iniciando a configuracao/verificacao do WSL2 e Ubuntu 20.04..."

    Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Windows-Subsystem-Linux -NoRestart
    Enable-WindowsOptionalFeature -Online -FeatureName VirtualMachinePlatform -NoRestart

    $KernelUrl = "https://wslstorestorage.blob.core.windows.net/wslblob/wsl_update_x64.msi"
    $DownloadPath = "$env:TEMP\wsl_update_x64.msi"
    Invoke-WebRequest -Uri $KernelUrl -OutFile $DownloadPath
    Start-Process -FilePath msiexec -ArgumentList "/i", $DownloadPath, "/quiet", "/qn", "/norestart" -Wait

    wsl --set-default-version 2

    try {
        wsl.exe --install -d Ubuntu-20.04
        Start-Sleep -Seconds 30
        wsl.exe --set-version Ubuntu-20.04 2
    } catch {
        Write-Host "Nao foi possivel instalar o Ubuntu 20.04 usando 'wsl --install -d Ubuntu-20.04'. Tentando outra abordagem..." -ForegroundColor Yellow
        $UbuntuUrl = "https://aka.ms/wslubuntu2004"
        $DownloadPath = "$env:TEMP\Ubuntu_2004.appx"
        Invoke-WebRequest -Uri $UbuntuUrl -OutFile $DownloadPath
        Add-AppxPackage -Path $DownloadPath
    }
    Write-Host "============================================"
    Write-Host "WSL2 e Ubuntu 20.04 instalados com sucesso!" -ForegroundColor Green
    Write-Host "Reinicie o computador para concluir a instalacao e usar o WSL2 e o Ubuntu 20.04." -ForegroundColor Yellow
    Write-Host "============================================"
}
Write-Host "============================================"
Write-Host "Apos a reinicializacao, para executar o WSL2 e o Ubuntu 20.04, digite 'wsl' ou 'ubuntu2004' no PowerShell ou no prompt de comando." -ForegroundColor Green
Write-Host "============================================"
WaitForEscOrEnter
