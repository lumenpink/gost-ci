# Especificação Técnica: Ticket #42

## 1. Contexto e Problema
A variável de ambiente `CARGO_TARGET_X86_64_UNKNOWN_LINUX_MUSL_LINKER=musl-gcc` em `images/cross/Dockerfile` força o uso do wrapper `musl-gcc` do Debian.
Ao compilar programas Rust para o alvo `x86_64-unknown-linux-musl`, a injeção dos arquivos CRT do Debian sobre a biblioteca musl nativa do Rust produz duplicação de inicialização e causa encerramento imediato do processo por SIGSEGV (código 139).

## 2. Requisitos Técnicos
1. Remover a linha `ENV CARGO_TARGET_X86_64_UNKNOWN_LINUX_MUSL_LINKER=musl-gcc` de `images/cross/Dockerfile`.
2. Manter as configurações de cross-compilação para arquiteturas que efetivamente requerem toolchains cruzadas (ARM64, Windows MinGW).
3. Adicionar asserções de validação e mutação em `tests/test-cross-multiarch.sh` garantindo que `musl-gcc` não seja definido como linker em alvos musl x86_64.

## 3. Critérios de Aceite
- Execução de `tests/test-cross-multiarch.sh` 100% aprovada.
- `cccp check --strict` aprovado com 100% de conformidade.
