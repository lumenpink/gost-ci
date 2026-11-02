#!/usr/bin/env bash
# ==============================================================================
# Validação de Limitação de Concorrência do Cargo no Lauda (#47)
# ==============================================================================
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
LAUDA_DOCKERFILE="$REPO_ROOT/images/lauda/Dockerfile"

echo "=== [TEST] Validando limitação de concorrência em images/lauda/Dockerfile (#47) ==="

FAILURES=0

if [[ ! -f "$LAUDA_DOCKERFILE" ]]; then
    echo "❌ Arquivo $LAUDA_DOCKERFILE não encontrado!"
    exit 1
fi

echo -n "-> 1. Verificando ENV CARGO_BUILD_JOBS=1 em images/lauda/Dockerfile... "
if grep -q "ENV CARGO_BUILD_JOBS=1" "$LAUDA_DOCKERFILE"; then
    echo "✅ OK"
else
    echo "❌ FALHOU (ENV CARGO_BUILD_JOBS=1 ausente)"
    FAILURES=$((FAILURES + 1))
fi

echo -n "-> 2. Verificando cargo check -j 1 em images/lauda/Dockerfile... "
if grep -qE "cargo check.*-j 1" "$LAUDA_DOCKERFILE"; then
    echo "✅ OK"
else
    echo "❌ FALHOU (cargo check sem -j 1)"
    FAILURES=$((FAILURES + 1))
fi

if [[ $FAILURES -gt 0 ]]; then
    echo ">>> Falhas encontradas: $FAILURES"
    exit 1
fi

echo ">>> Todos os testes de limitação de concorrência passaram com sucesso!"
exit 0
