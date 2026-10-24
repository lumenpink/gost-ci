# Especificação Técnica — Provisão de Android SDK & NDK para Compilação de APKs (#24)

## 1. Contexto e Motivação
A esteira de CI/CD para compilação e entrega de APKs Android de projetos do ecossistema soberano (como `lauda` e `lacraia`) encontrava-se bloqueada ou dependente de artefatos estáticos manuais porque as imagens de CI soberanas (`gost-ci-cross`, `gost-ci-rust`) não dispunham do Android SDK, NDK nem do compilador `dx` (Dioxus CLI) instalados.

Conforme as diretrizes GOST de esteira hermética, reprodutível e soberana, todos os pipelines de empacotamento Android devem executar exclusivamente dentro de contêineres autônomos providos pela forge `gambi.2lp.in`, sem depender de ferramentas instaladas no host ou fallbacks degradados.

## 2. Requisitos Técnicos

### 2.1 Sub-Imagem Canônica `gost-ci-android`
- **Contexto**: `images/android/Dockerfile`
- **Destino no Registro**: `gambi.2lp.in/lumen/gost-ci-android:latest` e `gambi.2lp.in/lumen/gost-ci-android:ndk27-sdk34`
- **Base**: `gambi.2lp.in/lumen/mirror-debian:bookworm-slim` ou `gambi.2lp.in/lumen/gost-ci-cross:latest`
- **Android SDK**:
  - `ANDROID_HOME=/opt/android-sdk`
  - Command-Line Tools versão `11076708_latest` descompactado em `/opt/android-sdk/cmdline-tools/latest`
  - Pacotes SDK: `platform-tools`, `platforms;android-34`, `build-tools;34.0.0`
- **Android NDK**:
  - Versão: `r27c` (`android-ndk-r27c`)
  - Localização canônica: `ANDROID_NDK_HOME=/opt/android-ndk/android-ndk-r27c` e `NDK_HOME=/opt/android-ndk/android-ndk-r27c`
- **Java**:
  - `openjdk-17-jdk-headless` com `JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64`
- **Rust Toolchain & Targets**:
  - `RUST_VERSION=1.99.1` com `sccache` (`RUSTC_WRAPPER=/usr/local/bin/sccache`, `SCCACHE_DIR=/root/.cache/sccache`)
  - Targets Android instalados: `aarch64-linux-android` e `x86_64-linux-android`
- **Dioxus CLI (`dx`)**:
  - Binário oficial `dx` versão `v0.7.10` em `/usr/local/bin/dx`

### 2.2 Alvos Android na Imagem `images/cross/Dockerfile`
- Adição dos targets `aarch64-linux-android` e `x86_64-linux-android` ao `rustup target add` de `images/cross/Dockerfile` para suporte abrangente em builds cruzados.

## 3. Critérios de Aceite
1. Sub-imagem `images/android/Dockerfile` declarada formalmente com variáveis canônicas e ferramentas.
2. Inclusão de `gost-ci-android` no workflow de build Kaniko (`.forgejo/workflows/build-images.yml`) com tags `:latest` e `:ndk27-sdk34`.
3. Script de validação `tests/test-android-image.sh` testando a presença e integridade das variáveis, SDK, NDK, alvos Rust e binário `dx`.
4. Atualização dos testes de canonical tags (`tests/test-docker-canonical-tags.sh`).
5. Validação rigorosa pelo quality gate `cccp check --strict`.
