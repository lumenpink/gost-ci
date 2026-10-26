# Especificação Técnica — Base Soberana mirror-node:24-trixie-slim para gost-ci-android (#33)

## 1. Contexto e Motivação
A execução de workflows em contêiner (`container: image: gambi.2lp.in/lumen/gost-ci-android:latest`) no Forgejo Actions requer a presença do runtime Node.js no ambiente para execução de actions essenciais, como `actions/checkout@v4`, além de ferramentas de deploy em nuvem soberana baseadas em npm/npx (`npx wrangler r2`).
Como a imagem Android requer GLIBC >= 2.39 (Debian Trixie) para o Dioxus CLI (`dx` v0.7.10) e OpenJDK 21, a base canônica soberana alinhada às demais imagens do repositório (`gost-ci-wasm`) é:
`gambi.2lp.in/lumen/mirror-node:24-trixie-slim`.

## 2. Requisitos Técnicos
1. **Imagem Base no Dockerfile**:
   - `images/android/Dockerfile` deve utilizar `FROM gambi.2lp.in/lumen/mirror-node:24-trixie-slim`.
2. **Ambiente Node.js & Android**:
   - Node.js 24 e npm/npx disponíveis diretamente no PATH a partir da imagem base soberana.
   - Preservar Java 21 (`openjdk-21-jdk-headless`), Android SDK (`platform-tools`, `platforms;android-34`, `build-tools;34.0.0`), Android NDK r27c, Rust toolchain 1.99.1, sccache e Dioxus CLI (`dx`).
3. **Critérios de Validação**:
   - `tests/test-android-image.sh` deve auditar a base `mirror-node:24-trixie-slim`.
   - `tests/test_audit_base_images.sh` deve validar a conformidade das instruções FROM.
   - Conformidade estrita via `cccp check --strict`.
