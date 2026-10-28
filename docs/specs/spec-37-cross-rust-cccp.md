# Especificação: Inclusão do Utilitário CCCP CLI nas Imagens gost-ci-cross e gost-ci-rust

- **ID do Ticket:** #37
- **Status:** Aprovado
- **Autor:** Lumen
- **Alinhamento:** GOST 1.5.0 (Engenharia de Containers e Infraestrutura de CI)

## 1. Contexto & Motivação
As sub-imagens `gost-ci-cross` e `gost-ci-rust` atuam como ambientes canônicos de execução do `forgejo-runner` nas esteiras de desenvolvimento e integração contínua do cluster.
Todos os projetos normatizados pela GOST utilizam o `cccp` como ferramenta de auditoria (`cccp check --strict`), verificação de convenções de commit, sincronização e suporte a testes do ciclo DD-TDD.
A ausência do utilitário `cccp` nos containers de CI causava a omissão da etapa de auditoria de qualidade nos projetos em geral e quebras de testes de integração em ferramentas como o `pult`, cujo teste unitário/integrado valida a execução do `check_strict()`.

## 2. Requisitos Técnicos
1. **Instalação Canônica a partir da Banca:**
   - Os arquivos `images/cross/Dockerfile` e `images/rust/Dockerfile` devem instalar o utilitário `cccp` em `/usr/local/bin/cccp` com permissões de execução (+x).
   - O processo de instalação obtém o pacote pré-compilado para `x86_64-unknown-linux-musl` a partir da Banca (`https://banca.2lp.in/downloads/cccp/index.json`), com fallback seguro para o script de referência `cccp.sh` (`https://bucket.2lp.in/downloads/cccp/nightly/cccp.sh`).
2. **Verificação de Validade:**
   - Durante a construção das imagens, deve ser executado `cccp --version` (ou `cccp version`) para atestar a integridade do binário gerado.
3. **Auditoria de Teste Estático e Mutação:**
   - O script `tests/test-cross-multiarch.sh` deve auditar a presença da diretiva de instalação do `cccp` em `images/cross/Dockerfile` e `images/rust/Dockerfile`.
   - Teste de mutação dedicado para assegurar sensibilidade à ausência de `cccp` nos Dockerfiles.
4. **Documentação:**
   - Atualizar `README.md` refletindo a presença do utilitário `cccp` nas imagens.

## 3. Critérios de Aceitação & Rastreabilidade DD-TDD
- [x] **Fase 1 - Ticket:** Criado ticket #37 no Forgejo (`lumen/gost-ci`).
- [x] **Fase 2 - Branch:** Criada branch dedicada `feat/37-incluir-cccp-nos-containers`.
- [x] **Fase 3 - Doc/Spec:** Especificação formal elaborada neste documento.
- [x] **Fase 4 - Red Test:** Asserção em `tests/test-cross-multiarch.sh` falha antes da alteração dos Dockerfiles.
- [x] **Fase 5 - Green Implement:** Instalação do `cccp` inserida em `images/cross/Dockerfile` e `images/rust/Dockerfile`.
- [x] **Fase 6 - Refactor:** Alinhamento e clareza nas instruções de instalação e changelog.
- [x] **Fase 7 - Mutation Test:** Testes de mutação validando rejeição se o `cccp` for omitido.
- [ ] **Fase 8 - Quality Gate:** Auditoria e passagem dos testes locais.
- [ ] **Fase 9 - Close:** Merge e acionamento da esteira para publicação das imagens.
