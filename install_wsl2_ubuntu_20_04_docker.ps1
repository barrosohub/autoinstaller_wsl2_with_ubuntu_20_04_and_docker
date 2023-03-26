$OutputEncoding = [System.Text.Encoding]::UTF8
Set-ExecutionPolicy Bypass -Scope Process -Force

function InstallWsl2 {
    Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Windows-Subsystem-Linux -NoRestart
    Enable-WindowsOptionalFeature -Online -FeatureName VirtualMachinePlatform -NoRestart

    $KernelUrl = "https://wslstorestorage.blob.core.windows.net/wslblob/wsl_update_x64.msi"
    $DownloadPath = "$env:TEMP\wsl_update_x64.msi"
    Invoke-WebRequest -Uri $KernelUrl -OutFile $DownloadPath
    Start-Process -FilePath msiexec -ArgumentList "/i", $DownloadPath, "/quiet", "/qn", "/norestart" -Wait

    wsl --set-default-version 2 > Out-Null
}

function InstallUbuntu20_04 {
    try {
         Write-Host "Baixando e instalando o Ubuntu 20.04 via wsl..." -ForegroundColor Yellow
         wsl --install -d Ubuntu-20.04
     } catch {
         Write-Host "Não foi possível instalar o Ubuntu 20.04 via wsl ainda. Vamos tentar instalar via Appx..." -ForegroundColor Yellow
         Write-Host "Baixando e instalando o Ubuntu 20.04..." -ForegroundColor Yellow
         $UbuntuUrl = "https://aka.ms/wslubuntu2004"
         $DownloadPath = "$env:TEMP\Ubuntu_2004.appx"
         Invoke-WebRequest -Uri $UbuntuUrl -OutFile $DownloadPath
         Add-AppxPackage -Path $DownloadPath
     }
 }

function InstallDocker {    
    wsl.exe -d Ubuntu-20.04 --exec sh -c "wget -O ~/docker_install.sh https://raw.githubusercontent.com/barrosohub/docker_ce_ubuntu_20_04/main/install.sh \
&& chmod +x ~/docker_install.sh \
&& ~/docker_install.sh \
&& rm ~/docker_install.sh \
&& sudo service docker start"

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
    wsl.exe -d Ubuntu-20.04
}

if (-not (IsAdmin)) {
    Write-Host "Este script precisa ser executado como administrador." -ForegroundColor Red
    Write-Host "Por favor, clique com o botão direito do mouse deste arquivo, procure e selecione a opção 'Executar como administrador' ou 'Run as Administrator'." -ForegroundColor Yellow
    WaitForEscOrEnter
}

$wslFeature = Get-WindowsOptionalFeature -Online -FeatureName "Microsoft-Windows-Subsystem-Linux"

Write-Info "===================================================================="
Write-Info "Verificando o status do WSL... Aguarde, pode demorar alguns minutos!"
Write-Info "===================================================================="
Write-Host ""

if ($wslFeature.State -eq "Enabled") {
    Write-Host "WSL2 está instalado. " -NoNewLine
    Write-Host "[OK]" -ForegroundColor Green

    $ubuntuInstalled = (wsl.exe -l --quiet 2>&1 | Out-String).Replace("`r`n", "`n").Split("`n") -contains "Ubuntu-20.04"
    $ubuntuInitialized = (wsl.exe -d Ubuntu-20.04 --exec sh -c "echo 'test'" 2>&1 | Out-String).Replace("`r`n", "`n").Split("`n") -contains "test"

    if ($ubuntuInstalled -and $ubuntuInitialized -eq "true") {
        Write-Host "Notamos que o Ubuntu 20.04 está instalado corretamente no WSL. " -NoNewLine
        Write-Host "[OK]" -ForegroundColor Green

        $dockerCheck = wsl.exe -d Ubuntu-20.04 --exec sh -c "which docker"
        if (![string]::IsNullOrWhiteSpace($dockerCheck)) {
            Write-Host "Notamos que o Docker CE (Community Edition) está instalado corretamente no WSL. " -NoNewLine
            Write-Host "[OK]" -ForegroundColor Green
            RedirectIfDockerIsInstalled
        } else {
            Write-Host "Ok! Já que o WSL e o Ubuntu 20.04 estão instalados corretamente, vamos agora instalar o Docker CE!" -ForegroundColor Yellow
            InstallDocker
        }
    } elseif ($ubuntuInstalled) {
        Write-Host "Ubuntu 20.04 está instalado, mas não foi inicializado. Por favor, inicialize o Ubuntu 20.04 e configure o usuário e senha. Após isso, execute este script novamente." -ForegroundColor Yellow
        Write-Host "Tentando inicializar o Ubuntu 20.04... (se der algum erro, tente reiniciar sua máquina e tente rodar de novo)" -ForegroundColor Yellow
        wsl.exe -d Ubuntu-20.04
        WaitForEscOrEnter
    } else {
        Write-Host "Ubuntu 20.04 não está instalado. Vamos instalar agora!" -ForegroundColor Yellow
        InstallUbuntu20_04
        Write-Host ""
        Write-Host "============================================"
        Write-Host " Ubuntu 20.04 instalado com sucesso!" -ForegroundColor Green
        Write-Host "============================================"
        Write-Host ""
        Write-Host " Reinicie o computador para concluir a configuração do WSL2! Após isso, execute esse script novamente para prosseguirmos para a configuração do Ubuntu e instalação do Docker" -ForegroundColor Yellow
        Write-Host ""
    }
} else {
    Write-Info "Iniciando a configuracao/verificacao do WSL2 e Ubuntu 20.04..."

    InstallWsl2
    InstallUbuntu20_04    

    Write-Host ""
    Write-Host "============================================"
    Write-Host " WSL2 e Ubuntu 20.04 instalados com sucesso!" -ForegroundColor Green
    Write-Host "============================================"
    Write-Host ""
    Write-Host " Reinicie o computador para concluir a configuração do WSL2! Após isso, execute esse script novamente para prosseguirmos para a configuração do Ubuntu e instalação do Docker" -ForegroundColor Yellow
    Write-Host ""
}

WaitForEscOrEnter