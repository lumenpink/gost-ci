# Especificação Técnica — Publicação Exclusiva no Registry Soberano gambi.2lp.in (#21)

## 1. Contexto e Motivação
A infraestrutura soberana do ecossistema GOST conta com seu próprio Container Registry OCI integrado à forge Forgejo em `gambi.2lp.in`. A publicação de imagens no Docker Hub (`docker.io/lumenpink/*`) foi descontinuada para assegurar:
1. Autonomia operacional completa e independência de registries proprietários ou de terceiros.
2. Eliminação de credenciais externas expostas no ambiente de CI/CD (`DOCKERHUB_USERNAME` e `DOCKERHUB_TOKEN`).
3. Resolução dos problemas de sintaxe incompatíveis com Forgejo Actions no workflow de compilação de imagens (`build-images.yml`), onde o uso de URLs absolutas em `actions/checkout` gerava falhas nos runners.

---

## 2. Requisitos Mandatórios

### 2.1 Publicação Exclusiva em gambi.2lp.in
1. O workflow `.forgejo/workflows/build-images.yml` DEVE configurar o executor Kaniko para enviar as imagens compiladas **estritamente** para o endpoint `gambi.2lp.in/lumen/<imagem>:<tag>`.
2. Qualquer menção a `docker.io`, `lumenpink/` ou secrets `DOCKERHUB_*` DEVE ser totalmente eliminada do repositório.
3. Todas as 10 imagens especializadas do catálogo `gost-ci` devem ser publicadas no registry soberano, preservando a tag móvel `:latest` e suas respectivas tags canônicas de versão (definidas na Especificação #19):
   - `gost-ci-rust`: `:latest`, `:1.99.1`
   - `gost-ci-cross`: `:latest`, `:1.99.1`
   - `gost-ci-deploy`: `:latest`, `:node24`
   - `gost-ci-wasm`: `:latest`, `:1.99.1`
   - `gost-ci-shell`: `:latest`, `:0.28.1`
   - `gost-ci-php`: `:latest`, `:8.4`
   - `gost-ci-gui`: `:latest`, `:1.99.1`
   - `gost-ci-lauda`: `:latest`, `:1.99.1`
   - `gost-ci-banca`: `:latest`, `:node24`
   - `gost-ci-flutter`: `:latest`, `:android34`

### 2.2 Autenticação Soberana e Validação Fail-Fast
1. A autenticação do Kaniko no Forgejo Container Registry deve ser realizada contra o domínio `gambi.2lp.in` utilizando o usuário `lumen` e a credencial `GAMBI_2LP_IN_TOKEN`.
2. Cada job do workflow DEVE validar obrigatoriamente a presença de `GAMBI_2LP_IN_TOKEN`. Caso a variável/secret esteja vazia ou ausente, a execução DEVE abortar imediatamente (*fail-fast*) com mensagem de erro explícita e código de saída diferente de zero, impedindo compilações em vão.

### 2.3 Correção Sintática de Checkout Forgejo
1. Em todos os jobs do workflow, a instrução de checkout DEVE utilizar a sintaxe padrão suportada pelo Forgejo Actions:
   `uses: actions/checkout@v4`
2. A sintaxe de URL absoluta (`uses: https://github.com/actions/checkout@v4`) é estritamente proibida por causar erros de parsing no motor do Forgejo Runner.

### 2.4 Documentação
1. O arquivo `README.md` deve ser atualizado para orientar o consumo das imagens a partir de `gambi.2lp.in/lumen/gost-ci-*`.

---

## 3. Critérios de Aceite (DD-TDD)
1. **Fase 4 (Red Test):** O script `tests/test-gambi-registry.sh` deve falhar se houver qualquer ocorrência de `docker.io`, ausência do secret `GAMBI_2LP_IN_TOKEN` com fail-fast, ausência de destinos `gambi.2lp.in`, ou sintaxe imprópria de checkout.
2. **Fase 5 (Green Implement):** Workflow e documentação atualizados; teste deve passar com status verde.
3. **Fase 7 (Mutation Test):** Testes de mutação devem certificar que a reintrodução de `docker.io` ou remoção do fail-fast quebra a esteira de validação.
