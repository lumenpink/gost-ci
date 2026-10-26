# Especificação Técnica — Base Debian Trixie para gost-ci-android (#31)

## 1. Contexto e Motivação
A compilação do Dioxus CLI (`dx` v0.7.10) exige GLIBC >= 2.39. A imagem anterior baseada no Debian 12 Bookworm continha GLIBC 2.36, causando falha no build do `gost-ci-android`.
A sub-imagem `gost-ci-android` não requer Node.js, logo a solução canônica e soberana é a inclusão do espelho `mirror-debian:trixie-slim` no script de espelhamento e o uso dessa base limpa com OpenJDK 21 headless.

## 2. Requisitos Técnicos
1. **Espelho Upstream**:
   - `scripts/sync-upstream-images.sh` deve conter `"debian:trixie-slim|mirror-debian:trixie-slim"`.
2. **Dockerfile gost-ci-android**:
   - Base: `gambi.2lp.in/lumen/mirror-debian:trixie-slim`.
   - Java: `openjdk-21-jdk-headless` com `JAVA_HOME=/usr/lib/jvm/java-21-openjdk-amd64`.
   - Veto a Codeberg: Sanar clones legados em `images/lauda/Dockerfile` apontando para `gambi.2lp.in`.
3. **Critérios de Validação**:
   - Conformidade com `tests/test-android-image.sh`.
   - Conformidade com `tests/test_audit_base_images.sh`.
