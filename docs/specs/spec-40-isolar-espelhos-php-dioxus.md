# Especificação: Isolamento de Espelhos PHP e Pacote Local Dioxus CLI

- **ID do Ticket:** #40
- **Status:** Aprovado
- **Autor:** Lumen
- **Alinhamento:** GOST 1.5.0 (Engenharia de Containers e Infraestrutura Hermética de CI)

## 1. Contexto & Motivação
Durante a execução do workflow de compilação da matriz de containers (`gost-ci`), dois jobs falharam por oscilações e timeouts na rede externa upstream:
1. `gost-ci-php`: o Kaniko falhou com timeout de I/O tentando autenticar e baixar `composer:2` do Docker Hub (`auth.docker.io`). Além disso, a ferramenta auxiliar `mlocati/php-extension-installer` também apontava diretamente para o Docker Hub sem espelhamento.
2. `gost-ci-android` (e preventivamente `gost-ci-wasm`): o `curl` sofreu timeout de conexão de rede de mais de 2 minutos ao tentar baixar o binário do Dioxus CLI (`dx`) a partir de `github.com/DioxusLabs/dioxus/releases`.

Todas as diretivas `FROM` das imagens base do repositório já utilizam o registry interno (`gambi.2lp.in/lumen/mirror-*`). É imperativo estender esse isolamento hermético para:
- Estágios multi-stage (`COPY --from=...`).
- Binários externos compilados que possam ser distribuídos via Generic Packages do Forgejo (como já feito com o `cccp`).

## 2. Requisitos Técnicos

### 2.1 Espelhamento de Imagens Auxiliares do PHP
1. O utilitário `scripts/sync-upstream-images.sh` deve incluir na sua matriz de espelhos:
   - `composer:2` -> `mirror-composer:2`
   - `mlocati/php-extension-installer` -> `mirror-php-extension-installer:latest`
2. O arquivo `images/php/Dockerfile` deve substituir referências diretas ao Docker Hub por:
   - `COPY --from=gambi.2lp.in/lumen/mirror-php-extension-installer:latest /usr/bin/install-php-extensions /usr/local/bin/`
   - `COPY --from=gambi.2lp.in/lumen/mirror-composer:2 /usr/bin/composer /usr/bin/composer`

### 2.2 Distribuição Local do Dioxus CLI (`dx`)
1. O binário/tarball oficial `dx-x86_64-unknown-linux-gnu.tar.gz` na versão `v0.7.10` deve ser hospedado no Forgejo Generic Packages em:
   `https://gambi.2lp.in/api/packages/lumen/generic/dioxus/v0.7.10/dx-x86_64-unknown-linux-gnu.tar.gz`
2. Os arquivos `images/android/Dockerfile` e `images/wasm/Dockerfile` devem ser configurados para obter o tarball exclusivamente desse endpoint local:
   `curl -fsSL "https://gambi.2lp.in/api/packages/lumen/generic/dioxus/${DIOXUS_VERSION}/dx-x86_64-unknown-linux-gnu.tar.gz" | tar -xz -C /usr/local/bin`
3. Proibido manter qualquer chamada `curl` para `github.com/DioxusLabs/dioxus` nesses Dockerfiles.

### 2.3 Auditoria Automatizada e Regressão
1. A suíte de testes deve validar que:
   - `images/php/Dockerfile` não faz `COPY --from` de imagens externas.
   - `scripts/sync-upstream-images.sh` possui as entradas de `composer` e `php-extension-installer`.
   - `images/android/Dockerfile` e `images/wasm/Dockerfile` consomem `dx` da Generic Package de `gambi.2lp.in`.

## 3. Critérios de Aceitação & Rastreabilidade DD-TDD
- [x] **Fase 1 - Ticket:** Criado ticket #40 no Forgejo (`lumen/gost-ci`).
- [x] **Fase 2 - Branch:** Criada branch dedicada `fix/40-isolar-espelhos-php-dioxus`.
- [x] **Fase 3 - Doc/Spec:** Especificação formal elaborada neste documento.
- [x] **Fase 4 - Red Test:** Teste automatizado validando a ausência de chamadas externas de PHP multi-stage e Dioxus.
- [x] **Fase 5 - Green Implement:** Publicação do pacote `dioxus` no Forgejo, atualização de `sync-upstream-images.sh` e dos Dockerfiles.
- [x] **Fase 6 - Refactor:** Polimento e alinhamento de testes e scripts.
- [ ] **Fase 7 - Mutation Test:** Testes de mutação validando detecção de fugas de espelhos.
- [ ] **Fase 8 - Quality Gate:** Suíte de testes local aprovada com zero warnings.
- [ ] **Fase 9 - Close:** Atualização de documentação, changelog e fechamento formal com `(closes #40)`.
