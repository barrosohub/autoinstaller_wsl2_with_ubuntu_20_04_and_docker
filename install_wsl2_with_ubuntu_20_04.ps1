# Este script instala e configura o WSL2 com Ubuntu 20.04 no PowerShell

# Função para exibir mensagens formatadas
function Write-Info {
    param (
        [string]$Message
    )

    Write-Host ""
    Write-Host $Message -ForegroundColor Cyan
}

# Função para pausar a execução e esperar por ESC ou ENTER
function WaitForEscOrEnter {
    Write-Host "Pressione ESC ou ENTER para fechar a janela." -ForegroundColor Yellow

    do {
        $key = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
    } until ($key.VirtualKeyCode -eq 27 -or $key.VirtualKeyCode -eq 13)
    exit
}

# Verificando se o WSL já está instalado e funcionando
Write-Info "Verificando o status do WSL..."
if (Get-WindowsOptionalFeature -Online -FeatureName "Microsoft-Windows-Subsystem-Linux" | Where-Object -Property State -eq "Enabled") {
    Write-Info "WSL já está instalado e funcionando."
    
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

    if ($ubuntuInstalled) {
        Write-Info "Ubuntu 20.04 já está instalado no WSL2."

        # Informando como abrir o WSL
        Write-Host "Para abrir o WSL com Ubuntu 20.04, digite 'wsl' ou 'ubuntu2004' no PowerShell ou no prompt de comando." -ForegroundColor Green
        WaitForEscOrEnter
    }
} 

# Se o WSL não está instalado ou o Ubuntu 20.04 não foi encontrado, prossiga com a instalação
Write-Info "WSL não encontrado ou Ubuntu 20.04 não instalado. Iniciando a instalação do WSL2 e Ubuntu 20.04..."
Write-Info "Isso pode levar algum tempo, por favor aguarde."
Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Windows-Subsystem-Linux -NoRestart
Enable-WindowsOptionalFeature -Online -FeatureName VirtualMachinePlatform -NoRestart

# Baixando e instalando o kernel do WSL2
Write-Info "Baixando e instalando o kernel do WSL2..."
$KernelUrl = "https://wslstorestorage.blob.core.windows.net/wslblob/wsl_update_x64.msi"
$DownloadPath = "$env:TEMP\wsl_update_x64.msi"
Invoke-WebRequest -Uri $KernelUrl -OutFile $DownloadPath
Start-Process -FilePath msiexec -ArgumentList "/i", $DownloadPath, "/quiet", "/qn", "/norestart" -Wait

# Configurando o WSL2 como padrão
Write-Info "Configurando o WSL2 como padrão..."
wsl --set-default-version 2

# Instalando o Ubuntu 20.04
Write-Info "Instalando o Ubuntu 20.04..."
$UbuntuUrl = "https://aka.ms/wslubuntu2004"
$DownloadPath = "$env:TEMP\Ubuntu_2004.appx"
Invoke-WebRequest -Uri $UbuntuUrl -OutFile $DownloadPath
try {
    Add-AppxPackage -Path $DownloadPath
} catch {
    Write-Host "Não foi possível instalar o Ubuntu 20.04 usando Add-AppxPackage. Tentando outra abordagem..." -ForegroundColor Yellow
    New-WSLDistro -DistributionName Ubuntu-20.04 -Download -Verbose
}

# Mensagem de sucesso
Write-Host "WSL2 e Ubuntu 20.04 instalados com sucesso!" -ForegroundColor Green

# Informando como executar o WSL2
Write-Host "Para executar o WSL2 e o Ubuntu 20.04, digite 'wsl' ou 'ubuntu2004' no PowerShell ou no prompt de comando." -ForegroundColor Green
WaitForEscOrEnter
