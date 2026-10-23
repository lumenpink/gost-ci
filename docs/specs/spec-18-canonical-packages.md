# Especificação Técnica — Auditoria e Conformidade de Versão Canônica dos Pacotes (#18)

## 1. Contexto e Motivação
No ecossistema GOST, todos os projetos distribuem seus binários e pacotes compilados na infraestrutura soberana (Forgejo/Gambi em `git.2lp.in`, Cloudflare R2 e catálogo da Banca).
A especificação canônica de versionamento GOST (Seção 4) determina adesão estrita ao **Semantic Versioning 2.0.0** (`MAJOR.MINOR.PATCH[-PRERELEASE][+BUILD]`).

Foi identificado que determinados workflows de CI/CD concatenavam metadados dinâmicos de compilação (`+${DATE_STAMP}.${GIT_SHA}`) diretamente sobre o conteúdo do arquivo `VERSION`, o qual, gerado pelo CCCP/Gosplan, já continha metadados prévios (por exemplo: `0.1.0-dev.27+20261019.caf0cc7`). O resultado era a geração de strings com duplo delimitador `+` (ex: `0.1.0-dev.27+20261019.caf0cc7+20261023.8f3d610`), violando a especificação SemVer 2.0.0 e corrompendo manifestos e registries de pacotes.

## 2. Requisitos Mandatórios de Versionamento

### 2.1 Higienização e Derivação de Versão Canônica
1. **Canal Estável (`stable`):**
   - Quando disparado por tag Git (`refs/tags/v*` ou `refs/tags/*`), a versão canônica **DEVE** ser extraída diretamente da tag:
     ```bash
     VERSION="${REF#refs/tags/v}"
     ```
2. **Canal Noturno / Desenvolvimento (`nightly`):**
   - Quando derivado da branch de desenvolvimento ou pull request, o workflow **DEVE** higienizar a base de versão contida no arquivo `VERSION`, removendo qualquer metadado pré-existente antes da concatenação:
     ```bash
     BASE_VER=$(head -n 1 VERSION 2>/dev/null | cut -d'+' -f1 | tr -d ' \r\n' || echo "0.1.0-dev")
     GIT_SHA=$(git rev-parse --short HEAD)
     DATE_STAMP=$(date +%Y%m%d)
     VERSION="${BASE_VER}+${DATE_STAMP}.${GIT_SHA}"
     ```
   - O resultado **DEVE** conter exatamente um único prefixo semântico válido e no máximo um sufixo de build metadata precedido por `+`.

### 2.2 Validação SemVer 2.0.0 Canônica
A versão atribuída a qualquer pacote gerado **DEVE** obrigatoriamente validar contra a expressão regular SemVer 2.0.0 oficial:
```
^(0|[1-9][0-9]*)\.(0|[1-9][0-9]*)\.(0|[1-9][0-9]*)(-(0|[1-9][0-9]*|[0-9]*[a-zA-Z-][0-9a-zA-Z-]*)(\.(0|[1-9][0-9]*|[0-9]*[a-zA-Z-][0-9a-zA-Z-]*))*)?(\+[0-9a-zA-Z-]+(\.[0-9a-zA-Z-]+)*)?$
```
É expressamente vedada a existência de mais de um caractere `+` na string final de versão.

## 3. Critérios de Aceite
1. O script `tests/test-canonical-packages.sh` deve auditar a lógica de derivação de versão nos workflows de CI de geração de pacotes.
2. Nenhuma concatenação ingênua de `${BASE_VER}+` sobre versão já comitada contendo `+` é permitida.
3. Testes de mutação devem validar que versões com duplo `+` ou strings malformadas disparam falha na auditoria.
