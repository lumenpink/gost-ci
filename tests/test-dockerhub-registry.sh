#!/usr/bin/env bash
# tests/test-dockerhub-registry.sh — Validação estrita da migração para Docker Hub (#14)
set -eo pipefail

WORKFLOW=".forgejo/workflows/build-images.yml"
README="README.md"
LAUDA_DF="images/lauda/Dockerfile"

echo "★ Validando migração dos contêineres para Docker Hub..."

# 1. Nenhuma ocorrência de codeberg.org/lumenpink/gost-ci no workflow de imagens
if grep -q "codeberg.org/lumenpink/gost-ci" "$WORKFLOW"; then
  echo "FALHA: Referência a codeberg.org encontrada em $WORKFLOW" >&2
  exit 1
fi

# 2. Presença de autenticação Docker Hub (index.docker.io e DOCKERHUB secrets)
grep -q "index.docker.io" "$WORKFLOW" || { echo "FALHA: Autenticação do Docker Hub ausente no Kaniko config" >&2; exit 1; }
grep -q "DOCKERHUB_USERNAME" "$WORKFLOW" || { echo "FALHA: Secret DOCKERHUB_USERNAME ausente em $WORKFLOW" >&2; exit 1; }
grep -q "DOCKERHUB_TOKEN" "$WORKFLOW" || { echo "FALHA: Secret DOCKERHUB_TOKEN ausente em $WORKFLOW" >&2; exit 1; }

# 3. Validação dos 10 destinos docker.io/lumenpink/gost-ci-*
IMAGES=(
  "gost-ci-rust"
  "gost-ci-cross"
  "gost-ci-deploy"
  "gost-ci-wasm"
  "gost-ci-shell"
  "gost-ci-php"
  "gost-ci-gui"
  "gost-ci-lauda"
  "gost-ci-banca"
  "gost-ci-flutter"
)

for img in "${IMAGES[@]}"; do
  if ! grep -q "docker.io/lumenpink/$img" "$WORKFLOW"; then
    echo "FALHA: Destino docker.io/lumenpink/$img ausente em $WORKFLOW" >&2
    exit 1
  fi
done

# 4. Dockerfile do lauda não deve referenciar codeberg.org
if grep -q "codeberg.org/lumenpink" "$LAUDA_DF"; then
  echo "FALHA: $LAUDA_DF ainda aponta para codeberg.org" >&2
  exit 1
fi

# 5. README não deve instruir uso de codeberg.org para gost-ci
if grep -q "codeberg.org/lumenpink/gost-ci" "$README"; then
  echo "FALHA: $README ainda documenta imagens em codeberg.org" >&2
  exit 1
fi

echo "✔ Todas as verificações de Docker Hub foram aprovadas!"
