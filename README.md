# PowerShell Script para instalar e configurar WSL2, Ubuntu 20.04 e Docker

Este script automatiza o processo de instalação e configuração do WSL2 (Windows Subsystem for Linux) com o Ubuntu 20.04 e o Docker no Windows.

## Resumo do script

1. Verifica se o WSL2 está habilitado e se o Ubuntu 20.04 já está instalado.
2. Caso o WSL2 e o Ubuntu 20.04 já estejam instalados, o script instala o Docker no ambiente WSL.
3. Se o WSL2 não estiver habilitado, o script habilita o WSL2 e instala o Ubuntu 20.04.
4. Após a instalação do WSL2 e do Ubuntu 20.04, o script instala o Docker no ambiente WSL.

## Uso

1. Abra o PowerShell como administrador e execute o script.
2. Siga as instruções na tela.
3. Reinicie o computador, se necessário, para concluir a instalação.

## Funções principais

- `Write-Host`: Exibe informações no console.
- `Write-Info`: Exibe informações no console com cor ciano.
- `WaitForEscOrEnter`: Aguarda o usuário pressionar a tecla ESC ou ENTER para fechar a janela.

## Destaques do script

- `$OutputEncoding = [System.Text.Encoding]::UTF8`: Define a codificação de saída como UTF8.
- `Get-WindowsOptionalFeature`: Verifica se o WSL2 está habilitado no sistema.
- `Enable-WindowsOptionalFeature`: Habilita o WSL2 e o recurso de plataforma de máquina virtual no sistema.
- `Invoke-WebRequest`: Faz o download do kernel do WSL2 e do Ubuntu 20.04.
- `Start-Process`: Inicia a instalação do kernel do WSL2.
- `wsl --set-default-version 2`: Define a versão padrão do WSL como 2.
- `wsl.exe --install -d Ubuntu-20.04`: Instala o Ubuntu 20.04 no WSL2.
- `Add-AppxPackage`: Instala o Ubuntu 20.04 como uma alternativa, caso a instalação inicial falhe.
- `WaitForEscOrEnter`: Aguarda o usuário pressionar a tecla ESC ou ENTER para fechar a janela.
