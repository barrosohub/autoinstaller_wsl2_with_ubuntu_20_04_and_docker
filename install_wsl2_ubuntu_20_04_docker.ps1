$OutputEncoding = [System.Text.Encoding]::UTF8

function WaitForEscOrEnter {
    Write-Host ""
    Write-Host "Pressione ESC ou ENTER para fechar esta janela!" -ForegroundColor Yellow
    Write-Host ""
    do {
        $key = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
    } until ($key.VirtualKeyCode -eq 27 -or $key.VirtualKeyCode -eq 13)
    exit
}

function IsAdmin {
    $identity = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = New-Object Security.Principal.WindowsPrincipal($identity)
    $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

if (-not (IsAdmin)) {
    Write-Host "Este script precisa ser executado como administrador." -ForegroundColor Red
    Write-Host "Por favor, clique com o botão direito do mouse deste arquivo, procure e selecione a opção 'Executar como administrador' ou 'Run as Administrator'." -ForegroundColor Yellow
    WaitForEscOrEnter
}

function Write-Info {
    param ([string]$Message)
    Write-Host ""
    Write-Host $Message -ForegroundColor Cyan
}

$wslFeature = Get-WindowsOptionalFeature -Online -FeatureName "Microsoft-Windows-Subsystem-Linux"

function InstallDocker {
    Write-Host "Instalando Docker CE..."
    wsl.exe -d Ubuntu-20.04 --exec sh -c "wget -O ~/docker_install.sh https://raw.githubusercontent.com/barrosohub/docker_ce_ubuntu_20_04/main/install.sh"
    wsl.exe -d Ubuntu-20.04 --exec sh -c "chmod +x ~/docker_install.sh && ~/docker_install.sh && rm ~/docker_install.sh && sudo service docker start"
    Write-Host "============================================================" -ForegroundColor Green
    Write-Host " Docker CE (Community Edition) instalado com sucesso!" -ForegroundColor Green
    Write-Host "============================================================" -ForegroundColor Green
}

function RedirectToWSLTerminal {
    Write-Host ""
    Write-Host "Aguarde 5 segundos... Estamos redirecionando para o terminal do WSL..." -ForegroundColor Yellow
    Write-Host ""
    Start-Sleep -Seconds 5
    wsl.exe -d Ubuntu-20.04
}

if ($wslFeature.State -eq "Enabled") {
    Write-Info "WSL2 está instalado. [OK]"
    $dockerCheck =  wsl.exe -d Ubuntu-20.04 --exec sh -c "systemctl is-active docker"
    if ($dockerCheck -eq "active") {
        Write-Info "Docker CE (Community Edition) está instalado corretamente no WSL no Ubuntu 20.04. [OK]"
        RedirectToWSLTerminal
    } else {
        InstallDocker
        RedirectToWSLTerminal
    }
} else {
    Write-Info "Iniciando a configuração/verificação do WSL2 e Ubuntu 20.04..."

    Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Windows-Subsystem-Linux -NoRestart
    Enable-WindowsOptionalFeature -Online -FeatureName VirtualMachinePlatform -NoRestart

    $KernelUrl = "https://wslstorestorage.blob.core.windows.net/wslblob/wsl_update_x64.msi"
    $DownloadPath = "$env:TEMP\wsl_update_x64.msi"
    Invoke-WebRequest -Uri $KernelUrl -OutFile $
    Invoke-WebRequest -Uri $KernelUrl -OutFile $DownloadPath
    Start-Process -FilePath msiexec -ArgumentList "/i", $DownloadPath, "/quiet", "/qn", "/norestart" -Wait

    wsl --set-default-version 2

    try {
        wsl.exe --install -d Ubuntu-20.04
        Start-Sleep -Seconds 30

        wsl.exe --set-version Ubuntu-20.04 2
    } catch {
        Write-Host "Não foi possivel instalar o Ubuntu 20.04 usando 'wsl --install -d Ubuntu-20.04'. Tentando outra abordagem..." -ForegroundColor Yellow
        $UbuntuUrl = "https://aka.ms/wslubuntu2004"
        $DownloadPath = "$env:TEMP\Ubuntu_2004.appx"
        Invoke-WebRequest -Uri $UbuntuUrl -OutFile $DownloadPath
        Add-AppxPackage -Path $DownloadPath
    }
    Write-Host ""
Write-Host "============================================"
Write-Host " WSL2 e Ubuntu 20.04 instalados com sucesso!" -ForegroundColor Green
Write-Host "============================================"
Write-Host ""
Write-Host " Reinicie o computador para concluir a configuração do WSL2! Após isso, execute esse script novamente para prosseguirmos para a configuração do Ubuntu e instalação do Docker" -ForegroundColor Yellow
Write-Host ""
}

WaitForEscOrEnter