# Spec 15: Inclusão Hermética de Rustfmt e Clippy nas Imagens CI

## 1. Contexto e Motivação
A diretriz GOST estipula que imagens de CI/CD devem ser atômicas, herméticas e autocontidas. Esteiras de compilação e teste não devem instalar ferramentas, toolchains ou componentes adicionais via internet em tempo de execução.

Atualmente, `images/cross/Dockerfile` e `images/rust/Dockerfile` instalam o toolchain Rust com a opção `--profile minimal`, omitindo `rustfmt` e `clippy`. Isso forçava os workflows a tentarem instalar esses linters em tempo de execução, violando o princípio de atomicidade.

## 2. Requisitos Técnicos
1. **Adição Compulsória de Componentes:**
   Em `images/cross/Dockerfile` e `images/rust/Dockerfile`, a instalação do rustup deve adicionar explicitamente os componentes `rustfmt` e `clippy`:
   ```bash
   rustup component add rustfmt clippy
   ```
2. **Preservação de Targets Multiarch:**
   Todos os alvos cross-compilados (`x86_64-unknown-linux-musl`, `aarch64-unknown-linux-musl`, `x86_64-pc-windows-gnu`, etc.) e ferramentas (`cargo-zigbuild`, `ziglang`, `musl-tools`) devem ser preservados integralmente.
3. **Verificação de Sanidade:**
   O script de teste `tests/test_dockerfiles.sh` deve auditar estritamente a presença de `rustfmt` e `clippy` nos Dockerfiles de `cross` e `rust`.
