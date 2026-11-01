# Especificação Técnica: Ticket #43

## 1. Contexto e Problema
Repositórios híbridos (como `navalha` e `ayvu`) dependem tanto de compilação cruzada para alvos nativos (Linux, Windows) quanto da geração de módulos WebAssembly para frontends web via `wasm-pack`.
A sub-imagem `gost-ci-cross` não continha o utilitário `wasm-pack` nem o alvo `wasm32-unknown-unknown`, gerando falha imediata na esteira de CI com `wasm-pack: command not found`.

## 2. Requisitos Técnicos
1. Incluir o alvo `wasm32-unknown-unknown` no `rustup target add` de `images/cross/Dockerfile`.
2. Declarar a variável `ENV WASM_PACK_VERSION=v0.13.1` e instalar o binário estático oficial em `/usr/local/bin/wasm-pack`.
3. Adicionar asserções de validação e mutação em `tests/test-cross-multiarch.sh`.
4. Atualizar o resumo de capacidades em `README.md`.

## 3. Critérios de Aceite
- Execução de `tests/test-cross-multiarch.sh` 100% aprovada.
- Suíte completa de testes em `tests/*.sh` aprovada.
- `cccp check --strict` aprovado com 100% de conformidade Gosplan.

## 4. Status de Resolução (Fase 9)
- **Status**: Concluído e Aprovado.
- **Data**: 2026-11-01
- **Laudo**: Adicionados wasm-pack v0.13.1 e target wasm32-unknown-unknown em images/cross/Dockerfile. Asserções e testes de mutação aprovados com 100% no cccp check.
