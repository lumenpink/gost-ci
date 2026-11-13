# Especificação Técnica — Ticket #52
## Incorporar kontur e kt nas Imagens de CI

- **Ticket:** #52
- **Branch:** `feat/52-incorporar-kontur-e-kt-nas-imagens-de-ci`
- **Data:** 2026-11-13
- **Autor:** Lumen Pink (Baquara)

---

## 1. Contexto e Motivação
Para garantir hermeticidade completa e proteção da Natasha nos próximos 6 meses, as ferramentas essenciais do ecossistema de desenvolvimento e governança GOST devem residir pré-instaladas nas imagens de CI (`images/cross` e `images/rust`).

Além de `cccp`, `lunokhod` e `gossnab`/`gn` (incorporados no Ticket #51), o controlador de telemetria e fronteira `kontur` (e seu atalho `kt`) passa a integrar o conjunto nativo de utilitários em `/usr/local/bin/`.

---

## 2. Requisitos e Implementação
- **`images/cross/Dockerfile`:**
  - Instalar `/usr/local/bin/kontur` a partir de `generic/kontur/nightly/kontur-linux-amd64`.
  - Instalar `/usr/local/bin/kt` a partir de `generic/kontur/nightly/kt-linux-amd64`.
- **`images/rust/Dockerfile`:**
  - Instalar os mesmos binários universais estáticos musl.
- **`docs/catalogo-de-imagens.md`:**
  - Documentar a presença de `kontur` (`kt`) na tabela da matriz de imagens.

---

## 3. Critérios de Aceite e Validação
- Os binários `kontur` e `kt` devem ser extraídos e marcados como executáveis (`chmod +x`).
- O teste `tests/test-dev-ecosystem-tools.sh` deve auditar a presença de `kontur` e `kt` em `cross` e `rust`.
- Mutação verificando a sensibilidade à ausência de `kontur`/`kt`.
- Suíte completa de testes de regressão aprovada com 100% de sucesso.
