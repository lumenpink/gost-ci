#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DOCKERFILE="$REPO_ROOT/images/flutter/Dockerfile"
WORKFLOW="$REPO_ROOT/.forgejo/workflows/build-images.yml"
README="$REPO_ROOT/README.md"

echo "=== Teste Red/Green: Sub-imagem gost-ci-flutter ==="

# 1. Existência do Dockerfile
if [ ! -f "$DOCKERFILE" ]; then
    echo "FALHA: $DOCKERFILE não existe" >&2
    exit 1
fi

# 2. Validação de conteúdo essencial do Dockerfile
grep -q "FLUTTER_HOME" "$DOCKERFILE" || { echo "FALHA: FLUTTER_HOME ausente no Dockerfile" >&2; exit 1; }
grep -q "ANDROID_HOME" "$DOCKERFILE" || { echo "FALHA: ANDROID_HOME ausente no Dockerfile" >&2; exit 1; }
grep -q "openjdk-17-jdk" "$DOCKERFILE" || { echo "FALHA: OpenJDK 17 ausente no Dockerfile" >&2; exit 1; }
grep -q "flutter precache" "$DOCKERFILE" || { echo "FALHA: Precache do Flutter ausente no Dockerfile" >&2; exit 1; }

# 3. Validação do Workflow de CI
grep -q "build-flutter" "$WORKFLOW" || { echo "FALHA: Job build-flutter ausente no workflow de CI" >&2; exit 1; }
grep -q "gambi.2lp.in/lumen/gost-ci-flutter" "$WORKFLOW" || { echo "FALHA: Destino da imagem no registry soberano ausente no CI" >&2; exit 1; }

# 4. Validação do README
grep -q "gost-ci-flutter" "$README" || { echo "FALHA: Imagem não documentada no README.md" >&2; exit 1; }

echo "✅ Todos os testes de conformidade da sub-imagem gost-ci-flutter passaram!"
