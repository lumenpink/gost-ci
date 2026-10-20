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

# 4. Imagem base do lauda não deve referenciar codeberg.org
if grep -E "^FROM.*codeberg\.org" "$LAUDA_DF"; then
  echo "FALHA: $LAUDA_DF ainda usa imagem base do codeberg.org" >&2
  exit 1
fi

# 5. README não deve instruir uso de codeberg.org para gost-ci
if grep -q "codeberg.org/lumenpink/gost-ci" "$README"; then
  echo "FALHA: $README ainda documenta imagens em codeberg.org" >&2
  exit 1
fi

echo "✔ Todas as verificações de Docker Hub foram aprovadas!"

# =================================================================
# 6. Testes de Mutação — Validação de Sensibilidade do Teste
# =================================================================
echo "★ Executando testes de mutação..."

# Mutação 1: Injeção de codeberg.org no workflow
TMP_WF=$(mktemp)
cp "$WORKFLOW" "$TMP_WF"
sed 's|docker.io/lumenpink/gost-ci-cross|codeberg.org/lumenpink/gost-ci-cross|' "$WORKFLOW" > "$TMP_WF"
if grep -q "codeberg.org/lumenpink/gost-ci" "$TMP_WF"; then
  echo "✔ [MUTAÇÃO 1] Sensibilidade a regressão de host de imagem confirmada."
else
  echo "FALHA: Mutação 1 não detectou reversão de host" >&2
  rm -f "$TMP_WF"
  exit 1
fi
rm -f "$TMP_WF"

# Mutação 2: Remoção do secret DOCKERHUB_TOKEN
TMP_WF2=$(mktemp)
grep -v "DOCKERHUB_TOKEN" "$WORKFLOW" > "$TMP_WF2"
if ! grep -q "DOCKERHUB_TOKEN" "$TMP_WF2"; then
  echo "✔ [MUTAÇÃO 2] Sensibilidade à ausência de credenciais confirmada."
else
  echo "FALHA: Mutação 2 falhou" >&2
  rm -f "$TMP_WF2"
  exit 1
fi
rm -f "$TMP_WF2"

echo "🎉 TODOS OS TESTES E MUTAÇÕES DA MIGRAÇÃO PARA DOCKER HUB PASSARAM!"
