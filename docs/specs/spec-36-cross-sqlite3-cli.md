# Especificação: Inclusão do Utilitário CLI sqlite3 na Imagem gost-ci-cross

- **ID do Ticket:** #36
- **Status:** Aprovado
- **Autor:** Lumen
- **Alinhamento:** GOST 1.5.0 (Engenharia de Containers / CI Soberana)

## 1. Contexto & Motivação
A sub-imagem `gost-ci-cross` atua como o ambiente canônico de execução do `forgejo-runner` sob a tag `ubuntu-latest`.
Diversos fluxos de integração e verificação de infraestrutura soberana (como a rotina de snapshot a quente do Forgejo em `baquara-infra`) demandam o utilitário de linha de comando `sqlite3` e os headers `libsqlite3-dev` para validar a integridade de bancos relacionais em pipelines herméticos.

## 2. Requisitos Técnicos
1. **Pacotes APT Obrigatórios:**
   - O arquivo `images/cross/Dockerfile` deve incluir explicitamente os pacotes:
     - `sqlite3` (binário da CLI oficial);
     - `libsqlite3-dev` (headers e biblioteca para compilação/linkagem).
2. **Validação de Teste Multiarch:**
   - O script `tests/test-cross-multiarch.sh` deve auditar estaticamente o Dockerfile para assegurar a presença de `sqlite3` e `libsqlite3-dev`.
3. **Imutabilidade e Limpeza:**
   - Manter a diretiva de remoção de listas apt (`rm -rf /var/lib/apt/lists/*`) preservando o tamanho otimizado da camada.

## 3. Critérios de Aceitação & Rastreabilidade DD-TDD
- [x] **Fase 1 - Ticket:** Criado ticket #36 no Forgejo (`lumen/gost-ci`).
- [x] **Fase 2 - Branch:** Criada branch dedicada `feat/36-cross-sqlite3-cli`.
- [x] **Fase 3 - Doc/Spec:** Especificação formal elaborada neste documento.
- [ ] **Fase 4 - Red Test:** Asserção em `tests/test-cross-multiarch.sh` falha antes da alteração do Dockerfile.
- [ ] **Fase 5 - Green Implement:** Pacotes `sqlite3` e `libsqlite3-dev` inseridos em `images/cross/Dockerfile`.
- [ ] **Fase 6 - Refactor:** Alinhamento limpo da lista de dependências no Dockerfile.
- [ ] **Fase 7 - Mutation Test:** Cobertura de rejeição caso `sqlite3` seja omitido.
- [ ] **Fase 8 - Quality Gate:** Auditoria `cccp check --strict` e passagem da suíte de testes.
- [ ] **Fase 9 - Close:** Fechamento e publicação da imagem atualizada.
