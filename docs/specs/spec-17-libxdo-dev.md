# Especificação Técnica — Inclusão de `libxdo-dev` nas Imagens `cross` e `gui` (#17)

## 1. Contexto e Motivação
A esteira de integração do ecossistema Sovereign Lumen e especificamente o binário `mandu-mobile` (que integra crates de desktop como `muda` e `libxdo-sys`) necessitam da biblioteca `libxdo` (`-lxdo`) para linkagem bem-sucedida.

Conforme as diretrizes GOST de esteira hermética e atômica, é expressamente vedada a instalação ad-hoc de pacotes (`apt-get install`) durante etapas de CI. Qualquer biblioteca nativa necessária para compilação ou linkagem deve residir permanentemente nas imagens especializadas publicadas pelo repositório `gost-ci`.

## 2. Requisitos Técnicos

### 2.1 Sub-imagem `gost-ci-cross` (`images/cross/Dockerfile`)
- Instalação declarativa de `libxdo-dev` ao lado de `libglib2.0-dev`, `libwebkit2gtk-4.1-dev` e `libasound2-dev`.
- Preservação da toolchain Rust 1.99.1 e alvos multiarch.

### 2.2 Sub-imagem `gost-ci-gui` (`images/gui/Dockerfile`)
- Instalação declarativa de `libxdo-dev` e `libglib2.0-dev`.
- Preservação da toolchain Rust 1.99.1.

## 3. Critérios de Aceite
1. Validação estrita via script de teste automatizado `tests/test-cross-multiarch.sh` e `tests/test-libxdo-desktop.sh`.
2. O Dockerfile de `cross` e de `gui` incluem `libxdo-dev`.
3. Teste de mutação confirmando a sensibilidade à ausência de `libxdo-dev`.
4. Conformidade estrita GOST através de `cccp check --strict`.
