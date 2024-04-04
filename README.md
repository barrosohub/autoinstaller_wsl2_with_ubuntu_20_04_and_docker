# 🚀 Instalação do WSL2 e Docker no Ubuntu 20.04 🎉

![WSL2 e Docker no Ubuntu 20.04](https://i.ibb.co/234Ccf7/WSL-DOCKER-1.png)

Bem-vindo a este guia fácil, rápido para instalar e configurar o WSL2 e o Docker no Ubuntu 20.04 no Windows! Este script de PowerShell faz todo o trabalho pesado por você, verificando se o WSL2 e o Ubuntu 20.04 estão instalados e, se necessário, instalando e configurando o Docker.

## 📋 Requisitos

- Windows 10, 11 ou Windows Server com suporte ao WSL2.
- Acesso à internet para baixar pacotes e atualizações.

## 🛠️ Como usar

1. Pressione **Win + R** para abrir a janela Executar.
2. Digite `powershell.exe -Command "Start-Process powershell.exe -Verb runAs"` e pressione **Enter**. Isso abrirá o PowerShell como administrador. (se aparecer alguma caixa de confirmação, confirme a execução)

3. Copie e Cole o seguinte comando no PowerShell e pressione **Enter**. Se aparecer alguma mensagem, selecione a opção "S" (Sim) ou "Y" (Yes):
```powershell
Set-ExecutionPolicy -Scope LocalMachine -ExecutionPolicy Bypass
```

4. Copie e Cole o seguinte comando no PowerShell e pressione **Enter**:

```powershell
$DownloadPath = "$([Environment]::GetFolderPath([Environment+SpecialFolder]::UserProfile))\Downloads"; Invoke-WebRequest -Uri https://raw.githubusercontent.com/barrosohub/autoinstaller_wsl2_with_ubuntu_20_04_and_docker/master/install_wsl2_ubuntu_20_04_docker.ps1 -OutFile "$DownloadPath\install_wsl2_ubuntu_20_04_docker.ps1"; Copy-Item "$DownloadPath\install_wsl2_ubuntu_20_04_docker.ps1" "$DownloadPath\autoinstall_wsl.ps1"; Remove-Item "$DownloadPath\install_wsl2_ubuntu_20_04_docker.ps1"; Start-Process explorer.exe -ArgumentList "/select, `"$DownloadPath\autoinstall_wsl.ps1`""
```

5. Execute o arquivo **autoinstall_wsl.ps1** como administrador. Para fazer isso, clique com o botão direito do mouse no ícone do PowerShell e selecione "Executar como administrador" ou "Run as Administrator". 📥
6. O script verificará se o WSL2 e o Ubuntu 20.04 estão instalados. Se não estiverem, ele iniciará o processo de instalação. 🧪
7. Caso o WSL2 e o Ubuntu 20.04 estejam instalados corretamente, o script verificará se o Docker está instalado no WSL. Se não estiver, ele instalará o Docker. 🐳
*(Após ter instalado o WSL pela primeira vez na sua máquina, **você precisa reiniciar pelo menos 1 vez**.)*
8. Ao final do processo, o terminal será redirecionado para o WSL com o Ubuntu 20.04 e o Docker instalados. 🎯
9. Pressione `ESC` ou `ENTER` para fechar a janela do PowerShell quando solicitado. 🚪

**OBSERVAÇÃO IMPORTANTE:**

Se em algum momento o script redirecionar você para o terminal WSL antes de terminar todas as etapas, execute de novo, **COMO ADMINISTRADOR**, o arquivo **autoinstall_wsl.ps1** que está na sua pasta/diretório **Downloads**. Um indicativo que todas as etapas foram finalizadas **COM SUCESSO**, são os **3 OK's** verdes que aparecem conforme imagem abaixo: 

![image (5)](https://github.com/barrosohub/autoinstaller_wsl2_with_ubuntu_20_04_and_docker/assets/12834525/88acb0d4-bb3c-4fb2-bbb6-c9d953ade583)

## 🌟 Funcionalidades

- Verifica se o PowerShell está sendo executado como administrador.
- Verifica se o WSL2 e o Ubuntu 20.04 estão instalados.
- Instala e configura o WSL2 e o Ubuntu 20.04, se necessário.
- Verifica se o Docker está instalado no Ubuntu 20.04 no WSL.
- Instala o Docker no Ubuntu 20.04, se necessário.
- Redireciona o usuário para o terminal do WSL com o Ubuntu 20.04 e o Docker instalados.

## 🤝 Suporte

Caso encontre algum problema ou tenha dúvidas, sinta-se à vontade para abrir um issue ou enviar uma mensagem. Estamos aqui para ajudar! 💡

Boa sorte e divirta-se com o WSL2 e o Docker no Ubuntu 20.04! 🎉🥳
