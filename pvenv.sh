#!/bin/bash
# Data: 2023-12-21
# Autor: Giovani Rorato
# Script para configurar um ambiente de desenvolvimento Python com JupyterLab
# Uso: curl -sSL <URL do Script no GitHub> | bash

# Para o script se qualquer comando falhar
set -e

# Identificação do Sistema Operacional
detectar_os() {
    case "$(uname -s)" in
        Linux*)     os=Linux;;
        Darwin*)    os=Mac;;
        *)          echo "Sistema Operacional não suportado."; exit 1;;
    esac
    echo "Sistema Operacional Detectado: $os"
}

# Função para verificar e instalar pyenv
verificar_instalar_pyenv() {
    if ! command -v pyenv &> /dev/null; then
        echo "Pyenv não encontrado. Instalando..."
        if [ "$os" = "Linux" ]; then
            # Comandos para instalar pyenv em Linux
            curl https://pyenv.run | bash
        elif [ "$os" = "Mac" ]; then
            # Comandos para instalar pyenv em MacOS
            brew update
            brew install pyenv
        fi
    fi
}

# Função para atualizar o pyenv
atualizar_pyenv() {
    echo "Atualizando o pyenv..."
    pyenv update > /dev/null 2>&1 &
    echo "Pyenv atualizado com sucesso."
}

# Função para escolher o diretório de instalação
escolher_diretorio_instalacao() {
    read -p "Digite o caminho do diretório onde você deseja instalar: [($pwd)]" diretorio_instalacao
    if [ -z "$diretorio_instalacao" ]; then
        diretorio_instalacao=$(pwd)
    else
        # Verificar se o diretório existe, senão, criá-lo
        mkdir -p "$diretorio_instalacao"
    fi
    echo "O ambiente virtual será instalado em: $diretorio_instalacao"
}

# Função para configurar as opções de otimização com base na versão do Python, no ambiente e no hardware
configurar_otimizacoes() {
    echo "Configurando otimizações para Python $PYENV_VERSION no $os..."

    # Ajustar MAKEFLAGS com base no sistema operacional
    if [ "$os" = "Linux" ]; then
        MAKEFLAGS="-j$(nproc)"
    elif [ "$os" = "Mac" ]; then
        MAKEFLAGS="-j$(sysctl -n hw.ncpu)"
    fi

    if [[ "$PYENV_VERSION" =~ 3.12.* ]]; then
        # Otimizações para Python 3.12
        CFLAGS="-O3 -flto -march=native -mtune=native"
        CXXFLAGS="${CFLAGS}"
        LDFLAGS="${CFLAGS}"
        if [ "$os" = "Linux" ]; then
            PYTHON_CONFIGURE_OPTS="--enable-optimizations --with-lto --enable-shared"
        else
            PYTHON_CONFIGURE_OPTS="--with-lto --enable-shared"
        fi
    elif [[ "$PYENV_VERSION" =~ 3.11.* ]]; then
        # Otimizações para Python 3.11
        CFLAGS="-O3 -flto -march=native -mtune=native"
        CXXFLAGS="${CFLAGS}"
        LDFLAGS="${CFLAGS}"
        PYTHON_CONFIGURE_OPTS="--with-lto --enable-shared"
    else
        # Configurações padrão para outras versões
        CFLAGS="-O2 -flto"
        CXXFLAGS="${CFLAGS}"
        LDFLAGS="${CFLAGS}"
        PYTHON_CONFIGURE_OPTS="--enable-shared"
    fi

    # Exportar as variáveis
    export MAKEFLAGS CFLAGS CXXFLAGS LDFLAGS PYTHON_CONFIGURE_OPTS
}

# Função para instalar a versão do Python
instalar_python() {
    echo "Instalando a versão $PYENV_VERSION."

    # Definindo a variável de ambiente para a ordem dos bytes em sistemas macOS
    if [ "$os" = "Mac" ]; then
        export ax_cv_c_float_words_bigendian=no
    fi

    pyenv install --force "${PYENV_VERSION}"
    echo "Versão $PYENV_VERSION instalada com sucesso."
}


# Função para criar um ambiente virtual
criar_venv() {
    echo "Criando ambiente virtual..."
    pyenv virtualenv "${PYENV_VERSION}" venv-"${PYENV_VERSION}"
    pyenv local venv-"${PYENV_VERSION}"
    echo "Ambiente virtual criado com sucesso."
}

# Função para instalar e atualizar pip, jupyterlab
instalar_pacotes() {
    echo "Instalando e atualizando pip, jupyterlab..."
    pip install -Uv pip
    pip install -Uv jupyterlab
    echo "Pip, jupyterlab instalados e atualizados com sucesso."
}

# Função para executar o JupyterLab
executar_jupyterlab() {
    read -rp "Deseja executar o JupyterLab? (s/n) " execute_jupyterlab

    if [ "$execute_jupyterlab" = "s" ]; then
        echo "Executando o Jupyter-lab"
        jupyter-lab --no-browser --ip=0.0.0.0 --allow-root --NotebookApp.token='' &
    else
        echo "O Jupyter-lab não será executado"
    fi
}

# Função principal
main() {
    # Detectar e configurar baseado no Sistema Operacional
    detectar_os

    # Verificar e instalar pyenv se necessário
    verificar_instalar_pyenv

    # Atualizar pyenv
    atualizar_pyenv

    # Escolher o diretório de instalação
    escolher_diretorio_instalacao

    # Pergunta ao usuário qual versão do Python ele deseja usar
    echo "Escolha uma versão do Python:"
    PYENV_VERSIONS=$(pyenv install --list | grep -E '^\s*[2-3]\.[0-9]+\.[0-9]+$' | tail -10)
    echo "$PYENV_VERSIONS"
    read -rp "Digite a versão escolhida: " PYTHON_VERSION
    if [ -z "$PYTHON_VERSION" ]; then
        PYENV_VERSION=$(echo "$PYENV_VERSIONS" | tail -1 | tr -d ' ')
    else
        PYENV_VERSION=$PYTHON_VERSION
    fi
    export PYENV_VERSION

    echo "Versão do Python escolhida: $PYENV_VERSION"

    # Configurar otimizações específicas para a versão escolhida do Python
    configurar_otimizacoes

    # Instalar a versão do Python
    instalar_python

    # Instalar um virtualenv
    criar_venv

    # Desfazer as configurações de variáveis
    unset MAKEFLAGS CFLAGS CXXFLAGS LDFLAGS PYTHON_CONFIGURE_OPTS

    # Instalar e atualizar pip, jupyterlab
    instalar_pacotes

    # Perguntar ao usuário se ele deseja executar o JupyterLab
    executar_jupyterlab

    # Verificar o ambiente instalado no diretório local
    echo "Instalação concluída com sucesso! Versão instalada do Python venv-${PYENV_VERSION}."
    exit 0
}

# Chamar a função principal
main
