$OutputEncoding = [System.Text.Encoding]::UTF8

function Write-Info {
    param ([string]$Message)
    Write-Host ""
    Write-Host $Message -ForegroundColor Cyan
}

function WaitForEscOrEnter {
    Write-Host ""
    Write-Host "Pressione ESC ou ENTER para fechar a janela!" -ForegroundColor Yellow
    Write-Host ""
    do {
        $key = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
    } until ($key.VirtualKeyCode -eq 27 -or $key.VirtualKeyCode -eq 13)
    exit
}

# Verificando se o Ubuntu 20.04 esta instalado
$ubuntuInstalled = $true

Write-Info ""
Write-Info "   Verificando o status do WSL... Aguarde, pode demorar alguns minutos."
Write-Info ""
$wslFeature = Get-WindowsOptionalFeature -Online -FeatureName "Microsoft-Windows-Subsystem-Linux"

if ($wslFeature.State -eq "Enabled") {
    Write-Info "WSL2 esta instalado."

    if ($ubuntuInstalled) {
        Write-Info "Notamos que você ja tem o WSL rodando normal, e que o Ubuntu 20.04 esta instalado corretamente no WSL."
        Write-Host "Ok! Já que o WSL e o Ubuntu 20.04 estao instalados corretamente, vamos agora installar o Docker!"
        wsl.exe -d Ubuntu-20.04 --exec sh -c "wget -O ~/docker_install.sh https://raw.githubusercontent.com/barrosohub/docker_ce_ubuntu_20_04/main/install.sh"
        wsl.exe -d Ubuntu-20.04 --exec sh -c "chmod +x ~/docker_install.sh && ~/docker_install.sh && rm ~/docker_install.sh && sudo service docker start"
        Write-Host "============================================================" -ForegroundColor Green
        Write-Host " Docker instalado com sucesso!" -ForegroundColor Green
        Write-Host "============================================================" -ForegroundColor Green
        #crie um temporaizador de 5 segundos antes de iniciar a próxima etapa. A mensagem enquanto o temporizador executa deve ser: "Aguarde 5 segundos... Estamos recarregando o WSL..."
        Write-Host "Aguarde 5 segundos... Estamos recarregando o WSL..." -ForegroundColor Yellow
        Start-Sleep -Seconds 5
        wsl.exe -d Ubuntu-20.04 --exec sh -c "sudo service docker start"
        Write-Host "============================================================" -ForegroundColor Green
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
    Write-Host " WSL2 e Ubuntu 20.04 instalados com sucesso!" -ForegroundColor Green
    Write-Host "============================================"
    Write-Host ""
    Write-Host " Reinicie o computador para concluir a instalacao e usar o WSL2 e o Ubuntu 20.04." -ForegroundColor Yellow
    Write-Host ""
}

WaitForEscOrEnter
