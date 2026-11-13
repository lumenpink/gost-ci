# Especificação Técnica — Ticket #53
## Incorporar cccp, lunokhod e gossnab em todas as imagens e expurgar kontur

- **Ticket:** #53
- **Branch:** `fix/53-incorporar-cccp-lunokhod-e-gossnab-em-todas-as-imagens-e-expurgar-kontur`
- **Data:** 2026-11-13
- **Autor:** Lumen Pink (Baquara)

---

## 1. Contexto e Motivação
Todas as esteiras de CI dos repositórios sob a norma GOST executam tarefas de conformidade, qualidade e governança através do comando `cccp check --strict`. Para que esse comando funcione de forma 100% hermética e determinística em qualquer linguagem ou tecnologia (Rust, Shell, PHP, Wasm, GUI, Android, Deploy, etc.):
- O motor de regras Lua (`lunokhod`);
- O orquestrador de qualidade e governança (`cccp`);
- O gerenciador de catálogo SSOT e pacotes (`gossnab` e atalho `gn`);

devem estar universalmente instalados em `/usr/local/bin/` em **todas** as imagens de CI do catálogo `gost-ci`.

Adicionalmente, os binários de telemetria de borda e espelhamento `kontur` e `kt` não pertencem ao ambiente de compilação/teste das esteiras de CI e devem ser integralmente expurgados de qualquer imagem Docker.

---

## 2. Requisitos e Implementação
1. **Expurgo de kontur e kt:**
   - Remover downloads e referências a `kontur` e `kt` em `images/cross/Dockerfile` e `images/rust/Dockerfile`.
   - Garantir que nenhum Dockerfile contenha referências a `kontur` ou `kt`.
2. **Universalização do Trio Canônico:**
   - Instalar `cccp`, `lunokhod`, `gossnab` e `gn` em todas as sub-imagens ativas:
     - `images/rust`
     - `images/cross`
     - `images/wasm`
     - `images/gui`
     - `images/shell`
     - `images/php`
     - `images/deploy`
     - `images/lauda`
     - `images/android`
     - `images/flutter`
     - `images/python`
     - `images/go`
     - `images/banca`
3. **Catálogo de Imagens:**
   - Atualizar `docs/catalogo-de-imagens.md` refletindo a presença universal do trio canônico e ausência de `kontur`/`kt`.

---

## 3. Critérios de Aceite e Validação
- Teste automatizado `tests/test-dev-ecosystem-tools.sh` validando a presença do trio em todas as imagens e garantindo ausência estrita de `kontur` e `kt`.
- Mutações testando detecção de ferramenta ausente e detecção de reintrodução de `kontur`.
- Testes de regressão do `gost-ci` 100% verdes.

## 4. Status e Resultados
- Status: Concluído e Pronto para Fechamento (Fase 9).
- `kontur` e `kt` expurgados com sucesso de `images/cross` e `images/rust`.
- `cccp`, `lunokhod` e `gossnab` (`gn`) incorporados em todas as 13 sub-imagens de CI (`rust`, `cross`, `wasm`, `gui`, `shell`, `php`, `deploy`, `lauda`, `android`, `flutter`, `python`, `go`, `banca`).
- Testes automatizados e mutações 100% aprovados.
