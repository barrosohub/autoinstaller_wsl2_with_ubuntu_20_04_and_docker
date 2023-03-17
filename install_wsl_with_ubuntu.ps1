# Este script instala e configura o WSL2 com Ubuntu 20.10 no PowerShell

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

    # Informando como abrir o WSL
    Write-Host "Para abrir o WSL, digite 'wsl' no PowerShell ou no prompt de comando." -ForegroundColor Green
    WaitForEscOrEnter
} else {
    # Instalando o WSL
    Write-Info "WSL não encontrado. Iniciando a instalação do WSL2 e Ubuntu 20.10..."
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

    # Instalando o Ubuntu 20.10
    Write-Info "Instalando o Ubuntu 20.10..."
    $UbuntuUrl = "https://aka.ms/wsl-ubuntu-2010"
    $DownloadPath = "$env:TEMP\Ubuntu_2010.appx"
    Invoke-WebRequest -Uri $UbuntuUrl -OutFile $DownloadPath
    Add-AppxPackage -Path $DownloadPath

    # Mensagem de sucesso
    Write-Host "WSL2 e Ubuntu 20.10 instalados com sucesso!" -ForegroundColor Green

    # Informando como executar o WSL2
    Write-Host "Para executar o WSL2 e o Ubuntu 20.10, digite 'wsl' ou 'ubuntu2010' no PowerShell ou no prompt de comando." -ForegroundColor Green
    WaitForEscOrEnter
}
