# 🐧 WSL2 e Docker no Ubuntu 20.04 🐳

Este script de PowerShell instala e configura o WSL2 e o Docker no Ubuntu 20.04 no Windows. Ele verifica se o WSL2 e o Ubuntu 20.04 estão instalados e, se necessário, instala e configura o Docker.

## 📋 Requisitos

- Windows 10, 11 ou Windows Server com suporte ao WSL2.
- Acesso à internet para baixar pacotes e atualizações.

## 🚀 Como usar

1. Baixe o arquivo [install_wsl2_ubuntu_20_04_docker.ps1](install_wsl2_ubuntu_20_04_docker.ps1), e execute como administrador. Para fazer isso, clique com o botão direito do mouse no ícone do PowerShell e selecione "Executar como administrador" ou "Run as Administrator".
2. O script verificará se o WSL2 e o Ubuntu 20.04 estão instalados. Se não estiverem, ele iniciará o processo de instalação.
3. Caso o WSL2 e o Ubuntu 20.04 estejam instalados corretamente, o script verificará se o Docker está instalado no WSL. Se não estiver, ele instalará o Docker.
4. Ao final do processo, o terminal será redirecionado para o WSL com o Ubuntu 20.04 e o Docker instalados.
5. Pressione ESC ou ENTER para fechar a janela do PowerShell quando solicitado.

## 🔍 O que o script faz

- Verifica se o PowerShell está sendo executado como administrador.
- Verifica se o WSL2 e o Ubuntu 20.04 estão instalados.
- Instala e configura o WSL2 e o Ubuntu 20.04, se necessário.
- Verifica se o Docker está instalado no Ubuntu 20.04 no WSL.
- Instala o Docker no Ubuntu 20.04, se necessário.
- Redireciona o usuário para o terminal do WSL com o Ubuntu 20.04 e o Docker instalados.

## 💬 Suporte

Caso encontre algum problema ou tenha dúvidas, sinta-se à vontade para abrir um issue ou enviar uma mensagem.

🎉 Boa sorte e divirta-se com o WSL2 e o Docker no Ubuntu 20.04! 🥳
