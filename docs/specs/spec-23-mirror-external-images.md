# Especificação Técnica — Espelhamento e Governança de Imagens Base Upstream (#23)

## 1. Contexto e Motivação
O ecossistema GOST fundamenta-se nos princípios de soberania tecnológica, reprodutibilidade hermética e capacidade estrita de operação offline. As esteiras de integração e entrega contínua (CI/CD) não devem depender de conectividade externa com registries públicos de terceiros durante seus ciclos de compilação regulares.

Atualmente, os Dockerfiles mantidos em `images/*` realizam download direto de imagens do Docker Hub público (`node:24-bookworm-slim`, `node:24-trixie-slim`, `debian:bookworm-slim`, `php:8.4-cli`). Essa dependência acarreta:
1. Vulnerabilidade a flutuações e indisponibilidades de conexão externa.
2. Penalização por bloqueios de taxa (*rate limits*) de provedores públicos.
3. Impossibilidade de execução hermética de compilações em ambientes isolados com `--network none`.

Para mitigar esses riscos, a presente especificação estabelece o mecanismo canônico de espelhamento periódico das imagens base no Container Registry soberano (`gambi.2lp.in`) e a conversão de todos os manifestos de construção (`Dockerfile`) para consumo estrito do espelho local.

---

## 2. Requisitos Mandatórios

### 2.1 Matriz Canônica de Imagens Base e Espelhos Soberanos
Todas as imagens base upstream utilizadas pelo catálogo `gost-ci` devem possuir uma réplica correspondente no registry soberano `gambi.2lp.in/lumen/*`:

| Imagem Upstream | Imagem Espelho Canônica (Soberana) | Finalidade no gost-ci |
| :--- | :--- | :--- |
| `node:24-bookworm-slim` | `gambi.2lp.in/lumen/mirror-node:24-bookworm-slim` | Base para rust, cross, deploy, gui, shell, banca |
| `node:24-trixie-slim` | `gambi.2lp.in/lumen/mirror-node:24-trixie-slim` | Base para wasm (Dioxus / toolchain moderno) |
| `debian:bookworm-slim` | `gambi.2lp.in/lumen/mirror-debian:bookworm-slim` | Base para flutter / Android toolchain |
| `php:8.4-cli` | `gambi.2lp.in/lumen/mirror-php:8.4-cli` | Base para testes e QA de módulos PHP |

Imagens internas compostas (como `images/lauda/Dockerfile`) devem referenciar exclusivamente a imagem soberana já produzida pelo próprio `gost-ci`:
- De: `docker.io/lumenpink/gost-ci-rust:latest`
- Para: `gambi.2lp.in/lumen/gost-ci-rust:latest`

### 2.2 Política de Blindagem dos Dockerfiles
1. É estritamente vedada a declaração direta de registries públicos (`docker.io`, `ghcr.io`, `quay.io`, etc.) ou nomes curtos implícitos do Docker Hub (ex.: `FROM node:24-bookworm-slim`) em qualquer `Dockerfile` sob `images/`.
2. Toda instrução `FROM` deve referenciar explicitamente o prefixo `gambi.2lp.in/lumen/`.

### 2.3 Script de Sincronização e Atualização (`scripts/sync-upstream-images.sh`)
O repositório deve fornecer um utilitário canônico com os seguintes comportamentos:
1. **Autenticação Segura:** Autentica-se contra `gambi.2lp.in` utilizando a variável de ambiente `GAMBI_2LP_IN_TOKEN`. Caso a variável não esteja definida ou seja vazia, o script DEVE abortar com código de saída diferente de zero (*fail-fast*).
2. **Idempotência:** Realiza `docker pull` da origem upstream, `docker tag` para a denominação soberana e `docker push` para `gambi.2lp.in/lumen/*`.
3. **Auditoria / Dry-Run:** Aceita o parâmetro `--dry-run` para listar as imagens alvo e verificar configurações sem efetuar o push.

### 2.4 Esteira Periódica de Auto-Atualização
O workflow `.forgejo/workflows/sync-mirrors.yml` deve permitir:
1. Disparo manual via `workflow_dispatch`.
2. Execução programada semanal (`schedule`) para manter os espelhos atualizados contra correções de segurança das distribuições Debian/Node upstream.

---

## 3. Critérios de Aceite e Qualidade (DD-TDD)
1. **Fase 4 (Red Test):** Script de auditoria `tests/test_audit_base_images.sh` deve falhar se qualquer `Dockerfile` contiver referência a registry externo não espelhado ou se o script `scripts/sync-upstream-images.sh` estiver ausente.
2. **Fase 5 (Green Implement):** Dockerfiles atualizados e script implementado; todos os testes devem passar.
3. **Fase 7 (Mutation Test):** Teste de mutação deve injetar intencionalmente `FROM debian:latest` ou omitir o token de autenticação e verificar que o teste barra a modificação com saída de erro imediata.
