# pvenv

Script interativo para configurar ambientes Python com **pyenv** e **JupyterLab**.
Funciona em Linux e macOS e instala automaticamente o `pyenv` caso ele não esteja
presente no sistema.

## Requisitos
- `curl` e `git` disponíveis no `PATH`;
- Para macOS é necessário ter o [Homebrew](https://brew.sh/) instalado;
- Dependências de compilação para o Python (por exemplo, `build-essential` em
  distribuições Debian/Ubuntu ou `xcode-select --install` no macOS).

## Como usar
Execute diretamente o script via `curl`:

```bash
curl -sSL https://raw.githubusercontent.com/giovanirorato/pvenv/main/pvenv -o pvenv.sh && bash pvenv.sh
```

Durante a execução você poderá:
1. Informar o diretório onde o ambiente será criado (padrão: diretório atual);
2. Escolher a versão do Python a instalar a partir de uma lista fornecida;
3. Optar por iniciar o JupyterLab ao final do processo.

O script criará um virtualenv chamado `venv-<versao>` utilizando o pyenv.

## Avisos de segurança
Caso opte por iniciar o JupyterLab, ele será executado com `--allow-root` e sem
token por padrão. Para ambientes acessíveis publicamente recomenda-se definir um
token ou senha (consulte `jupyter lab --help`).

## Remoção
Para desfazer a instalação basta remover o diretório escolhido e, se necessário,
utilizar `pyenv uninstall <versao>` para apagar a versão instalada.

## Contribuindo
Contribuições são bem-vindas. Sinta-se à vontade para abrir Issues ou Pull
Requests com melhorias.

## Licença
Distribuído sob a licença [Apache 2.0](LICENSE).
