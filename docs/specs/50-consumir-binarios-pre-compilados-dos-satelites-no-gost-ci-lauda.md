# Especificação Técnica — Consumir Binários Pré-compilados dos Satélites no Lauda (#50)

## 1. Contexto e Motivação
Na esteira de compilação da Run #1751 (e anteriormente na #1721), a etapa `Build & Push gost-ci-lauda` falhou com `signal: 9, SIGKILL: kill` durante a compilação de dependências (`crc24`, `pgp`, `darling`) dentro do executor Kaniko.
A tentativa anterior (#47) de mitigar o estouro de memória restringindo a concorrência via `CARGO_BUILD_JOBS=1` e `cargo check -j 1` mostrou-se insuficiente diante da árvore profunda de dependências compiladas em cascata para três repositórios completos (`ishcondidim`, `papeli`, `urupema`) dentro do ambiente de build de imagens.

Considerando que os projetos satélites do ecossistema já possuem esteiras de integração e entrega contínua dedicadas que compilam e publicam seus próprios binários estáticos oficiais para `linux-x86_64` no Forgejo da Gambi (`gambi.2lp.in`), a compilação ou checagem a partir do código-fonte em tempo de construção da imagem torna-se redundante, onerosa e frágil.

Adicionalmente, o compilador wrapper `sccache` deve ser integralmente preservado nas imagens base (`rust`, `cross`, `wasm`, `gui`), mantendo os ganhos comprovados de aceleração de compilação com cache nas esteiras de CI.

## 2. Requisitos Técnicos

1. **Instalação Canônica dos Binários Satélites em `images/lauda/Dockerfile`**:
   - Baixar os binários executáveis oficiais pré-compilados diretamente das releases canônicas do Forgejo:
     - `https://gambi.2lp.in/lumen/ishcondidim/releases/download/latest/ishcondidim` -> `/usr/local/bin/ishcondidim`
     - `https://gambi.2lp.in/lumen/papeli/releases/download/latest/papeli` -> `/usr/local/bin/papeli`
     - `https://gambi.2lp.in/lumen/urupema/releases/download/latest/urupema` -> `/usr/local/bin/urupema`
   - Conceder permissão de execução (`chmod +x`).
   - Remover os comandos de clonagem de repositórios (`git clone`) e compilação/checagem (`cargo check`).
   - Remover diretivas obsoletas de concorrência (`CARGO_BUILD_JOBS=1`).

2. **Validação Automatizada e Sensibilidade a Mutantes**:
   - Atualizar a suíte de testes em `tests/` para verificar a presença das URLs canônicas de download dos três satélites e a ausência de comandos `cargo check` em `images/lauda/Dockerfile`.
   - Adicionar testes de mutação para garantir a detecção de ausência de qualquer um dos três binários.

## 3. Critérios de Aceite
- `images/lauda/Dockerfile` instala os três binários satélites diretamente em `/usr/local/bin/` sem invocar `cargo check` ou clonar repositórios Git.
- Todos os testes automatizados e de mutação em `tests/` passam com 100% de sucesso.
- Auditoria estrita Gosplan (`cccp check --strict`) aprovada com 100% de conformidade.

## 4. Status e Resultados
- Status: Concluído e Pronto para Fechamento (Fase 9).
- Substituída a compilação ad-hoc (`git clone` e `cargo check`) pelo download direto dos binários pré-compilados em `images/lauda/Dockerfile`.
- `sccache` mantido 100% ativo e configurado nas imagens base (`rust`, `cross`, `wasm`, `gui`).
- Testes automatizados e de mutação implementados em `tests/test-lauda-canonical-binaries.sh`.
- Auditoria estrita `cccp check --strict` aprovada com 100% de conformidade.
