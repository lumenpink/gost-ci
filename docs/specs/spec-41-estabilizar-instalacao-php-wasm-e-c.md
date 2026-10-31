# Especificação Técnica: Estabilização de Imagens PHP, WASM e Condensação de README

**Ticket Associado:** #41  
**Branch:** `fix/41-estabilizar-instalacao-php-wasm-e-c`  
**Norma:** GOST 1.5.0 / 2.0.0 (Regra GOST-20)

## 1. Contexto & Motivação
A esteira de construção de imagens de CI (`.forgejo/workflows/build-images.yml`) registrou falhas na compilação das sub-imagens:
1. `gost-ci-php`: o comando `pecl install xdebug` falha frequentemente com `No releases available for package "pecl.php.net/xdebug"` devido a instabilidade e quedas na infraestrutura upstream do PECL. A imagem já dispõe da ferramenta oficial `install-php-extensions` (copiada do espelho local), projetada especificamente para contornar falhas de rede e compilar extensões PHP com máxima confiabilidade.
2. `gost-ci-wasm`: o download de binários do `sccache` apontando para o GitHub apresentou timeout de rede (`curl (28)`). É indispensável configurar retries robustos (`--retry 5 --retry-connrefused --retry-delay 2`).
3. Auditoria de conformidade GOST (`cccp check --strict`): o arquivo `README.md` excede o teto de 50 linhas imposto pela norma GOST-20 (com 154 linhas). O detalhamento técnico e catálogo de imagens devem residir em `docs/catalogo-de-imagens.md`, mantendo o `README.md` conciso e estritamente aderente.

## 2. Requisitos Técnicos
1. **Sub-imagem PHP (`images/php/Dockerfile`)**:
   - Substituir a invocação manual do `pecl` por `install-php-extensions xdebug`.
   - Manter as configurações de runtime em `conf.d` (`xdebug.mode=off` e `display_errors=Off`).
2. **Sub-imagem WASM e correlatas (`images/wasm/Dockerfile`)**:
   - Adicionar parâmetros de resiliência ao `curl` na obtenção do `sccache`: `--retry 5 --retry-connrefused --retry-delay 2`.
3. **Documentação e SSOT (`README.md` e `docs/catalogo-de-imagens.md`)**:
   - Mover a tabela descritiva e seções arquiteturais extensas para `docs/catalogo-de-imagens.md`.
   - Limitar `README.md` a no máximo 45 linhas, contendo título, resumo executivo, links canônicos para documentação e rodapé regulamentar.
4. **Testes de Contrato e Mutação (`tests/test-php-wasm-resilience.sh`)**:
   - Criar teste automatizado validando a presença de `install-php-extensions xdebug` em `images/php/Dockerfile`.
   - Validar flags de retry no download de `sccache` em `images/wasm/Dockerfile`.
   - Validar que `README.md` não excede 50 linhas.
   - Adicionar testes de sensibilidade contra mutações (ex: reintrodução de `pecl`, ausência de retries ou excesso de linhas).

## 3. Critérios de Aceitação
- Teste `tests/test-php-wasm-resilience.sh` passando com 100% de sucesso.
- Todos os testes de conformidade em `tests/*.sh` passando via `bash`.
- Auditoria `cccp check --strict` com índice de 100% de conformidade.

## 4. Status de Resolução (Fase 9)
- **Status**: Concluído e Aprovado.
- **Data**: 2026-10-31
- **Laudo**: Sub-imagem PHP migrada para install-php-extensions, flags de retries adicionadas em sccache e README condensado para 32 linhas (GOST-20). Todos os testes e quality gates aprovados com 100% de conformidade.


## 4. Status de Resolução (Fase 9)
- **Status**: Concluído e Aprovado.
- **Data**: 2026-10-31
- **Laudo**: Sub-imagem PHP migrada para install-php-extensions, flags de retries adicionadas em sccache e README condensado para 32 linhas (GOST-20). Todos os testes e quality gates aprovados com 100% de conformidade.

