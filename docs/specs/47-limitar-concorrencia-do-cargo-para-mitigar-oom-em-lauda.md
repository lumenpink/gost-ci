# Especificação Técnica — Limitar Concorrência do Cargo em Lauda (#47)

## 1. Contexto e Motivação
Na esteira de compilação da Run #1721, a etapa `Build & Push gost-ci-lauda` falhou com `signal: 9, SIGKILL: kill` durante a compilação das dependências `nom`, `chrono`, `mail-builder` e `mail-parser`.
O container Kaniko é executado no runner sob restrição de memória (`--memory=4.5g`). Como o Dockerfile do Lauda executa `cargo check` em cascata para `ishcondidim`, `papeli` e `urupema` sem teto de concorrência, o Cargo utiliza todos os núcleos disponíveis em paralelo, estourando a memória atribuída ao container.

## 2. Requisitos Técnicos
1. **Configuração de Concorrência Monothread no Dockerfile (`images/lauda/Dockerfile`)**:
   - Injetar variável de ambiente `ENV CARGO_BUILD_JOBS=1`.
   - Adicionar o argumento explícito `-j 1` nas invocações de `cargo check`.
2. **Validação Automatizada**:
   - Criar ou atualizar asserções de teste em `tests/` para verificar a presença de `CARGO_BUILD_JOBS=1` e `-j 1` no `images/lauda/Dockerfile`.
   - Implementar testes de mutação para garantir a obrigatoriedade da diretiva.

## 3. Status e Resultados
- Status: Em Desenvolvimento (Fase 3 - Spec).
- Conformidade estrita com GOST e CCCP.
