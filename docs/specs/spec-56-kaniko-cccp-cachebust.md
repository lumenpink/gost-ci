# Especificação do Ticket #56: Invalidar Cache do Kaniko ao Baixar `cccp`

## 1. Contexto e Motivação
Os Dockerfiles de `gost-ci` baixam `cccp-linux-amd64` via `RUN curl -fsSL https://gambi.2lp.in/api/packages/lumen/generic/cccp/nightly/cccp-linux-amd64`.
Como a string do `RUN` não muda entre releases do `cccp`, o Kaniko (`--cache=true`) reaproveitava camadas obsoletas, deixando as imagens com versões antigas do `cccp` (sem o subcomando `package`).

## 2. Requisitos
1. Adicionar `ARG CCCP_CACHEBUST=1` imediatamente antes de `RUN curl ... cccp-linux-amd64` em todos os Dockerfiles de `images/*/Dockerfile`.
2. Passar `--build-arg=CCCP_CACHEBUST=${{ github.sha }}-${{ github.run_id }}` em todas as chamadas Kaniko de `.forgejo/workflows/build-images.yml`.
