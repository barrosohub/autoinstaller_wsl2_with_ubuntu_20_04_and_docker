$OutputEncoding = [System.Text.Encoding]::UTF8
Set-ExecutionPolicy Bypass -Scope Process -Force

function InstallWsl2 {
    Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Windows-Subsystem-Linux -NoRestart
    Enable-WindowsOptionalFeature -Online -FeatureName VirtualMachinePlatform -NoRestart

    $KernelUrl = "https://wslstorestorage.blob.core.windows.net/wslblob/wsl_update_x64.msi"
    $DownloadPath = "$env:TEMP\wsl_update_x64.msi"
    Invoke-WebRequest -Uri $KernelUrl -OutFile $DownloadPath
    Start-Process -FilePath msiexec -ArgumentList "/i", $DownloadPath, "/quiet", "/qn", "/norestart" -Wait

    wsl --set-default-version 2

    Remove-Item -Path $DownloadPath
}

function InstallUbuntu {
    try {
         Write-Host "Baixando e instalando o Ubuntu via wsl..." -ForegroundColor Yellow
         wsl --install -d Ubuntu
     } catch {
         Write-Host "Nao foi possivel instalar o Ubuntu via wsl ainda. Vamos tentar instalar via Appx..." -ForegroundColor Yellow
         Write-Host "==============================================================="
         Write-Host "Baixando e instalando o Ubuntu... Aguarde..." -ForegroundColor Yellow
         Write-Host "==============================================================="
         $UbuntuUrl = "https://aka.ms/wslubuntu"
         $DownloadPath = "$env:TEMP\Ubuntu_2210.appx"
         Invoke-WebRequest -Uri $UbuntuUrl -OutFile $DownloadPath
         Add-AppxPackage -Path $DownloadPath
     }
 }

function InstallDocker {    
    wsl.exe -d Ubuntu --exec sh -c "wget -O ~/docker_install.sh https://raw.githubusercontent.com/barrosohub/install_docker_ce_on_ubuntu/main/install.sh"
    wsl.exe -d Ubuntu --exec sh -c "chmod +x ~/docker_install.sh && ~/docker_install.sh && rm ~/docker_install.sh && sudo service docker start"
    Write-Host "============================================================" -ForegroundColor Green
    Write-Host " Docker CE (Community Edition) instalado com sucesso!" -ForegroundColor Green
    Write-Host "============================================================" -ForegroundColor Green
    RedirectIfDockerIsInstalled
}

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

function Write-Info {
    param ([string]$Message)
    Write-Host ""
    Write-Host $Message -ForegroundColor Cyan
}

function RedirectIfDockerIsInstalled {
    Write-Host ""
    Write-Host "Aguarde 5 segundos... Estamos redirecionando para o terminal do WSL..." -ForegroundColor Yellow
    Write-Host ""
    Start-Sleep -Seconds 5
    wsl.exe -d Ubuntu
}

function AlertReboot {
    Write-Host ""
    Write-Host ""
    Write-Host " (ATENCAO) Reinicie o computador para concluir a configuracao do WSL2 com o Ubuntu! Apos isso, execute esse script novamente para prosseguirmos para a configuracao do Ubuntu e instalacao do Docker!" -ForegroundColor Yellow
    Write-Host ""
    Write-Host ""
}

if (-not (IsAdmin)) {
    Write-Host "Este script precisa ser executado como administrador." -ForegroundColor Red
    Write-Host "Por favor, clique com o botao direito do mouse deste arquivo, procure e selecione a opcao 'Executar como administrador' ou 'Run as Administrator'." -ForegroundColor Yellow
    WaitForEscOrEnter
}

$wslFeature = Get-WindowsOptionalFeature -Online -FeatureName "Microsoft-Windows-Subsystem-Linux"

Write-Info "===================================================================="
Write-Info "Verificando o status do WSL, Ubuntu, Docker e ambiente... Aguarde, pode demorar alguns minutos!"
Write-Info "===================================================================="
Write-Host ""

if ($wslFeature.State -eq "Enabled") {
    Write-Host "WSL2 esta instalado. " -NoNewLine
    Write-Host "[OK]" -ForegroundColor Green

    $ubuntuInstalled = (wsl.exe -l --quiet 2>&1 | Out-String).Replace("`r`n", "`n").Split("`n") -contains "Ubuntu"
    $ubuntuInitialized = (wsl.exe -d Ubuntu --exec sh -c "echo 'test'" 2>&1 | Out-String).Replace("`r`n", "`n").Split("`n") -contains "test"

    if ($ubuntuInstalled -and $ubuntuInitialized -eq "true") {
        Write-Host "Notamos que o Ubuntu esta instalado corretamente no WSL. " -NoNewLine
        Write-Host "[OK]" -ForegroundColor Green

        $dockerCheck = wsl.exe -d Ubuntu --exec sh -c "which docker"
        if (![string]::IsNullOrWhiteSpace($dockerCheck)) {
            Write-Host "Notamos que o Docker CE (Community Edition) esta instalado corretamente no WSL. " -NoNewLine
            Write-Host "[OK]" -ForegroundColor Green
            RedirectIfDockerIsInstalled
        } else {
            Write-Host "Ok! Ja que o WSL e o Ubuntu estao instalados corretamente, vamos agora instalar o Docker CE!" -ForegroundColor Yellow
            InstallDocker
        }
    } elseif ($ubuntuInstalled) {
        Write-Host "Ubuntu esta instalado, mas nao foi inicializado. Por favor, inicialize o Ubuntu e configure o usuario e senha. Apos isso, execute este script novamente." -ForegroundColor Yellow
        Write-Host "Tentando inicializar o Ubuntu... (se der algum erro, tente reiniciar sua maquina e tente rodar de novo)" -ForegroundColor Yellow
        wsl.exe -d Ubuntu
        WaitForEscOrEnter
    } else {
        Write-Host "Ubuntu nao esta instalado. Vamos instalar agora!" -ForegroundColor Yellow
        InstallUbuntu
        Write-Host ""
        Write-Host "============================================"
        Write-Host " Ubuntu instalado com sucesso!" -ForegroundColor Green
        Write-Host "============================================"
        AlertReboot
    }
} else {
    Write-Info "Iniciando a configuracao/verificacao do WSL2 e Ubuntu..."

    InstallWsl2
    InstallUbuntu

    Write-Host ""
    Write-Host "============================================"
    Write-Host " WSL2 e Ubuntu instalados com sucesso! Agora confira a instrucao abaixo!" -ForegroundColor Green
    Write-Host "============================================"
    AlertReboot
}

WaitForEscOrEnter
