# Especificação Técnica — Escalonamento em Ondas dos Jobs da Esteira (#48)

## 1. Contexto e Motivação
Na esteira de compilação de imagens (`build-images.yml`), quando há alterações em `.forgejo/` ou compilação manual (`workflow_dispatch`), os 13 jobs da matriz são disparados simultaneamente.
A execução paralela de múltiplos processos do Kaniko descompactando e fotografando rootfs inteiros, aliada a downloads volumosos de SDKs (Android, Flutter) e compilações Rust, satura a memória (16GB RAM) e causa pressão extrema no sistema (`systemd-journald under memory pressure`), culminando em falhas por timeout, erros transitórios 503 no proxy local e reinicialização inesperada do anfitrião.

## 2. Requisitos Técnicos
1. **Estruturação da Esteira em Ondas / Estágios com `needs:`**:
   - Organizar os jobs em ondas equilibradas para que as imagens leves e fundamentais executem primeiro, seguidas pelas intermediárias e, por fim, as pesadas:
     - **Onda 1 (Fundamentais e Leves)**: `build-rust`, `build-shell`, `build-python`, `build-go`, `build-php`.
     - **Onda 2 (Intermediárias)**: `build-wasm`, `build-deploy`, `build-gui`, `build-android`, `build-lauda` (depende de `build-rust`).
     - **Onda 3 (Pesadas)**: `build-banca`, `build-cross`, `build-flutter`.
   - Adicionar a cláusula `if: always() && !cancelled()` nos jobs dependentes para garantir que a falha em uma imagem de onda anterior não impeça a compilação das imagens das ondas seguintes caso tenham sido alteradas.
2. **Validação Automatizada e Testes**:
   - Criar `tests/test-pipeline-waves.sh` verificando a presença de `needs:` e a cláusula `if: always() && !cancelled()` nos jobs escalonados do workflow `build-images.yml`.
   - Implementar testes de mutação para assegurar a detecção da ausência de escalonamento.

## 3. Status e Resultados
- Status: Concluído e Fechado (Fase 9).
- Estruturação em 3 ondas sequenciais de execução implementada no workflow `build-images.yml`.
- Cláusula resiliente `if: always() && !cancelled()` aplicada em todos os 8 jobs dependentes.
- Testes automatizados e testes de mutação aprovados em `tests/test-pipeline-waves.sh`.
- Auditoria estrita `cccp check --strict` aprovada com 100% de conformidade.
