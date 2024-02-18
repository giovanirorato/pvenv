#!/bin/bash
# Data: 2024-02-17
# Autor: Giovani Rorato
# Script para configurar um ambiente de desenvolvimento Python com JupyterLab
# Uso: curl -sSL <URL do Script no GitHub> | bash

# Para o script se qualquer comando falhar e trata erros em pipelines
set -eo pipefail

# Identificação do Sistema Operacional
detectar_os() {
    case "$(uname -s)" in
        Linux*)     os=Linux;;
        Darwin*)    os=Mac;;
        *)          echo "Sistema Operacional não suportado." >&2; exit 1;;
    esac
    echo "Sistema Operacional Detectado: $os"
}

# Função para verificar e instalar pyenv
verificar_instalar_pyenv() {
    if ! command -v pyenv &> /dev/null; then
        echo "Pyenv não encontrado. Instalando..."
        if [ "$os" = "Linux" ]; then
            curl https://pyenv.run | bash
        elif [ "$os" = "Mac" ]; then
            brew update
            brew install pyenv
        fi
    fi
}

# Atualizar pyenv
atualizar_pyenv() {
    echo "Atualizando o pyenv..."
    pyenv update
    echo "Pyenv atualizado com sucesso."
}

# Escolher o diretório de instalação
escolher_diretorio_instalacao() {
    read -p "Digite o caminho do diretório onde você deseja instalar: [$(pwd)] " diretorio_instalacao
    diretorio_instalacao=${diretorio_instalacao:-$(pwd)}
    mkdir -p "$diretorio_instalacao" && cd "$diretorio_instalacao"
    echo "O ambiente virtual será instalado em: $diretorio_instalacao"
}

# Configurar otimizações
configurar_otimizacoes() {
    echo "Configurando otimizações para Python $PYENV_VERSION no $os..."
    local ncores=1
    if [ "$os" = "Linux" ]; then
        ncores=$(nproc)
    elif [ "$os" = "Mac" ]; then
        ncores=$(sysctl -n hw.ncpu)
    fi
    MAKEFLAGS="-j${ncores}"
    CFLAGS="-O2 -flto"
    CXXFLAGS="${CFLAGS}"
    LDFLAGS="${CFLAGS}"
    PYTHON_CONFIGURE_OPTS="--enable-shared"
    if [[ "$PYENV_VERSION" =~ 3\.(1[1-9]|[2-9])\..* ]]; then
        CFLAGS="-O3 -march=native -mtune=native"
        CXXFLAGS="${CFLAGS}"
        LDFLAGS="${CFLAGS}"
        PYTHON_CONFIGURE_OPTS+=" --enable-optimizations --with-lto"
    fi
    export MAKEFLAGS CFLAGS CXXFLAGS LDFLAGS PYTHON_CONFIGURE_OPTS
    echo "Otimizações configuradas com sucesso."
}

# Instalar a versão do Python
instalar_python() {
    echo "Instalando a versão $PYENV_VERSION."
    pyenv install --force "${PYENV_VERSION}"
    echo "Versão $PYENV_VERSION instalada com sucesso."
}

# Criar um ambiente virtual
criar_venv() {
    echo "Criando ambiente virtual..."
    pyenv virtualenv "${PYENV_VERSION}" venv-"${PYENV_VERSION}"
    pyenv local venv-"${PYENV_VERSION}"
    echo "Ambiente virtual criado com sucesso."
}

# Instalar e atualizar pip, jupyterlab
instalar_pacotes() {
    echo "Instalando e atualizando pip, jupyterlab..."
    pip install --upgrade pip jupyterlab
    echo "Pip, jupyterlab instalados e atualizados com sucesso."
}

# Executar o JupyterLab
executar_jupyterlab() {
    read -rp "Deseja executar o JupyterLab? (s/n) " execute_jupyterlab
    if [ "$execute_jupyterlab" = "s" ]; then
        jupyter-lab --no-browser --ip=0.0.0.0 --allow-root --NotebookApp.token=''
    else
        echo "O Jupyter-lab não será executado."
    fi
}

# Função principal
main() {
    detectar_os
    verificar_instalar_pyenv
    atualizar_pyenv
    escolher_diretorio_instalacao
    echo "Escolha uma versão do Python:"
    PYENV_VERSIONS=$(pyenv install --list | grep -E '^\s*[2-3]\.[0-9]+\.[0-9]+$' | tail -10)
    echo "$PYENV_VERSIONS"
    read -rp "Digite a versão escolhida: " PYTHON_VERSION
    PYENV_VERSION=${PYTHON_VERSION:-$(echo "$PYENV_VERSIONS" | tail -1 | tr -d ' ')}
    export PYENV_VERSION
    echo "Versão do Python escolhida: $PYENV_VERSION"
    configurar_otimizacoes
    instalar_python
    criar_venv
    instalar_pacotes
    executar_jupyterlab
    echo "Instalação concluída com sucesso! Versão instalada do Python venv-${PYENV_VERSION}."
}

# Chamar a função principal
main

