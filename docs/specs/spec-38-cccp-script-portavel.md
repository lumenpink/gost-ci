# Especificação: Instalação do CCCP via Script Portátil cccp.sh

- **ID do Ticket:** #38
- **Status:** Aprovado
- **Autor:** Lumen
- **Alinhamento:** GOST 1.5.0 (Engenharia de Containers e Infraestrutura de CI)

## 1. Contexto & Motivação
A compilação Kaniko no cluster Forgejo para as imagens `gost-ci-cross` e `gost-ci-rust` falhou na tentativa de execução do binário ELF `cccp` compilado com musl dinâmico (`/lib/ld-musl-x86_64.so.1`), resultando em erro `exit status 139` (segmentation fault) ou `exit status 127` (file not found) em ambiente glibc (`node:24-bookworm-slim`).
O utilitário oficial `cccp.sh` distribuído na Banca é um script POSIX puro sem dependências externas de compilação ou carregador de libc específico, garantindo execução universal e determinística tanto para auditoria GOST (`cccp check --strict`) quanto para suporte a testes.

## 2. Requisitos Técnicos
1. **Instalação Canônica Direta:**
   - Obter diretamente o script `https://bucket.2lp.in/downloads/cccp/nightly/cccp.sh` e salvá-lo em `/usr/local/bin/cccp`.
   - Conceder permissão de execução (`chmod +x /usr/local/bin/cccp`).
   - Validar com `cccp --help` durante a construção da imagem sem exigir repositório git ou dependências de linker.
2. **Dockerfiles Abrangidos:**
   - `images/cross/Dockerfile`
   - `images/rust/Dockerfile`
3. **Auditoria e Mutação:**
   - Preservar integridade dos testes de validação multiarch em `tests/test-cross-multiarch.sh`.

## 3. Critérios de Aceitação & Rastreabilidade DD-TDD
- [x] **Fase 1 - Ticket:** Criado ticket #38 no Forgejo (`lumen/gost-ci`).
- [x] **Fase 2 - Branch:** Criada branch dedicada `fix/38-cccp-script-portavel`.
- [x] **Fase 3 - Doc/Spec:** Especificação formal elaborada neste documento.
- [x] **Fase 4 - Red Test:** Teste estático validando a diretiva canônica direta via script.
- [x] **Fase 5 - Green Implement:** Dockerfiles atualizados com `curl -fsSL https://bucket.2lp.in/downloads/cccp/nightly/cccp.sh -o /usr/local/bin/cccp`.
- [x] **Fase 6 - Refactor:** Limpeza e documentação no CHANGELOG.
- [x] **Fase 7 - Mutation Test:** Verificação de sensibilidade a omissões.
- [x] **Fase 8 - Quality Gate:** Passagem de todos os testes locais.
- [x] **Fase 9 - Close:** Documentação finalizada e pronta para merge/publicação.
