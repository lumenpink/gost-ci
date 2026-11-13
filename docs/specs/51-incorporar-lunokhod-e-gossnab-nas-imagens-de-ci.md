# Especificação Técnica — Ticket #51
## Incorporar lunokhod e gossnab nas Imagens de CI

- **Ticket:** #51
- **Branch:** `feat/51-incorporar-lunokhod-e-gossnab-nas-imagens-de-ci`
- **Data:** 2026-11-12
- **Autor:** Lumen Pink (Baquara)

---

## 1. Contexto e Motivação
Durante a execução de esteiras de CI e tarefas de auditoria GOST (ex.: GOST-27 verificação de pureza de domínio e catálogo descentralizado de dependências), o utilitário `cccp` delega funções essenciais para os binários satélites canônicos:
- `lunokhod`: executor das regras de auditoria em Lua.
- `gossnab` (e atalho `gn`): resolvedor de catálogo SSOT e metadados de dependências na rede.

Anteriormente, tais ferramentas não estavam presentes nas imagens base `gost-ci-cross` e `gost-ci-rust`, o que gerava falhas de execução a menos que montadas manualmente pelo Runner.

Para garantir que as imagens sejam 100% autossuficientes e herméticas, os binários estáticos universais (`musl`) de `lunokhod`, `gossnab` e `gn` devem ser incorporados diretamente nos Dockerfiles consumindo os Generic Packages publicados na Gambi (`https://gambi.2lp.in/api/packages/lumen/generic/...`).

---

## 2. Requisitos e Implementação
- **`images/cross/Dockerfile`:**
  - Instalar `/usr/local/bin/lunokhod` a partir de `generic/lunokhod/nightly/lunokhod-linux-amd64`.
  - Instalar `/usr/local/bin/gossnab` a partir de `generic/gossnab/nightly/gossnab-linux-amd64`.
  - Instalar `/usr/local/bin/gn` a partir de `generic/gossnab/nightly/gn-linux-amd64`.
- **`images/rust/Dockerfile`:**
  - Instalar os mesmos binários universais para suportar auditoria direta em pipelines Rust.
- **`docs/catalogo-de-imagens.md`:**
  - Atualizar a matriz de imagens documentando a presença dos binários do ecossistema de desenvolvimento.

---

## 3. Critérios de Aceite e Validação
- Todos os binários devem estar presentes em `/usr/local/bin/` e marcados como executáveis (`chmod +x`).
- Teste automatizado dedicado `tests/test-dev-ecosystem-tools.sh` validando a presença de todos os endpoints e binários nos respectivos Dockerfiles.
- Mutação automatizada testando sensibilidade à ausência de ferramentas.
- Regressão de testes de CI (`test-canonical-packages.sh`, `test-sccache.sh`, `test-cross-multiarch.sh`) 100% verde.

---

## 4. Status e Resultados
- Status: Concluído e Pronto para Fechamento (Fase 9).
- Binários estáticos universais compilados contra musl libc e publicados no Forgejo Generic Packages da Gambi.
- Dockerfiles atualizados com consumo direto via curl.
- Testes automatizados e de mutação implementados e aprovados com 100% de conformidade.
