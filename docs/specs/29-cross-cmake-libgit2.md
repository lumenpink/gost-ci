# Especificação Técnica: Suporte a CMake e Toolchains para Libgit2 em gost-ci-cross

**Ticket Associado:** #29  
**Branch:** `feat/29-cross-cmake-libgit2`  
**Norma:** GOST 1.4.0

## 1. Objetivo
Incluir `cmake` e bibliotecas de suporte a C/SSL na imagem Docker `images/cross/Dockerfile` (`gost-ci-cross`), permitindo que compilações cruzadas de crates Rust com FFI nativo e compilação em C (especificamente `libgit2-sys` do crate `git2` com recursos completos de SSL) sejam construídas em pipelines CI para os alvos `x86_64-unknown-linux-musl`, `aarch64-unknown-linux-musl` e `x86_64-pc-windows-gnu`.

## 2. Requisitos e Critérios de Aceitação
1. **Dockerfile (`images/cross/Dockerfile`):**
   - Instalar `cmake` via `apt-get install`.
   - Garantir presença de `libssl-dev` e headers de desenvolvimento para alvos C.
2. **Testes Automatizados (`tests/test-cross-multiarch.sh`):**
   - Verificar a presença e declaração explícita de `cmake` em `images/cross/Dockerfile`.
   - Incluir teste de mutação para detecção de ausência do `cmake`.
