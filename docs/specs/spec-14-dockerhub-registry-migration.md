# Especificação Técnica — Migração do Registro de Contêineres para Docker Hub (#14)

## 1. Contexto e Motivação
Todas as imagens de contêineres do ecossistema GOST e satélites devem ser distribuídas através do **Docker Hub** (`docker.io/lumenpink/...`). A utilização prévia do registro de pacotes do Codeberg ocasionou esgotamento da cota de armazenamento de pacotes (HTTP 413 `enforcePackagesQuota`), além de divergir do padrão adotado em outros repositórios como o `fuxico` e `resenha`.

## 2. Requisitos da Esteira (`.forgejo/workflows/build-images.yml`)

### 2.1 Autenticação Kaniko no Docker Hub
A autenticação do Kaniko deve gerar o arquivo `/kaniko/.docker/config.json` contendo as credenciais do Docker Hub a partir das secrets `DOCKERHUB_USERNAME` e `DOCKERHUB_TOKEN`:
```json
{
  "auths": {
    "https://index.docker.io/v1/": {
      "auth": "<base64 DOCKERHUB_USERNAME:DOCKERHUB_TOKEN>"
    }
  }
}
```

### 2.2 Destino das Imagens
Todas as diretivas `--destination` nos jobs do Kaniko devem apontar para `docker.io/lumenpink/gost-ci-<nome>:<tag>`:
- `gost-ci-rust:latest` e `gost-ci-rust:1.98.1`
- `gost-ci-cross:latest` e `gost-ci-cross:1.98.1`
- `gost-ci-deploy:latest` e `gost-ci-deploy:node24`
- `gost-ci-wasm:latest` e `gost-ci-wasm:1.98.1`
- `gost-ci-shell:latest` e `gost-ci-shell:0.28.1`
- `gost-ci-php:latest` e `gost-ci-php:8.4`
- `gost-ci-gui:latest` e `gost-ci-gui:1.98.1`
- `gost-ci-lauda:latest`
- `gost-ci-banca:latest`
- `gost-ci-flutter:latest`

### 2.3 Referências Internas e Documentação
- `images/lauda/Dockerfile`: `FROM docker.io/lumenpink/gost-ci-rust:latest` (ou `lumenpink/gost-ci-rust:latest`).
- `README.md`: Atualizar todas as menções de imagens de `codeberg.org/lumenpink/gost-ci-*` para `docker.io/lumenpink/gost-ci-*`.

## 3. Critérios de Aceite
1. Nenhuma menção a `codeberg.org/lumenpink/gost-ci-` remanescente em workflows de build, Dockerfiles ou README.
2. Script de validação automatizada `tests/test-dockerhub-registry.sh` cobrindo todas as 10 imagens.
3. Conformidade integral nas auditorias de governança `cccp check --strict`.
