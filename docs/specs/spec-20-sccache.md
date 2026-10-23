# Especificação Técnica — Inclusão de `sccache` nas Imagens Rust de CI (#20)

## 1. Contexto e Motivação
O runner de CI (`forgejo-runner`) foi configurado para persistir cache de compilações entre execuções montando `/root/.cache/sccache` no HD1 (`/media/hd1/forgejo-cache/sccache`) e definindo variáveis de ambiente (`SCCACHE_DIR`, `SCCACHE_CACHE_SIZE`).
Entretanto, o cache permanecia vazio porque as imagens de CI (`rust`, `wasm`, `cross`, `gui`) não continham o binário `sccache` instalado.

Conforme as diretrizes GOST de esteira hermética e canônica, é expressamente vedada a instalação ad-hoc de pacotes durante etapas de execução ou gambiarras no runner. O compilador wrapper e o binário `sccache` devem residir permanentemente em `/usr/local/bin/sccache` nas imagens especializadas com toolchain Rust publicadas pelo repositório `gost-ci`.

## 2. Requisitos Técnicos

### 2.1 Versão do `sccache`
- Versão canônica: `v0.18.0` (`ENV SCCACHE_VERSION=v0.18.0`).
- Binário oficial compilado estaticamente para `x86_64-unknown-linux-musl`, descompactado em `/usr/local/bin/sccache`.
- Permissão de execução `+x` e validação imediata no build (`sccache --version`).

### 2.2 Sub-imagens afetadas
- `images/rust/Dockerfile` (também herança para `images/lauda/Dockerfile`)
- `images/wasm/Dockerfile`
- `images/cross/Dockerfile`
- `images/gui/Dockerfile`

## 3. Critérios de Aceite
1. Validação estrita via script de teste automatizado `tests/test-sccache.sh`.
2. Todos os quatro Dockerfiles declaram a instalação canônica do `sccache`.
3. Teste de mutação confirmando a sensibilidade à ausência de `sccache`.
4. Conformidade estrita GOST através de `cccp check --strict`.

## 4. Evidências de Validação
- Teste automatizado `tests/test-sccache.sh` executado e aprovado com 100% de sucesso.
- Validação de mutação aprovada para ausência na lista de ferramentas base.
- Instalação canônica declarada de forma consistente em `images/rust/Dockerfile`, `images/wasm/Dockerfile`, `images/cross/Dockerfile` e `images/gui/Dockerfile`.

