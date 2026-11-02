#!/usr/bin/env bash
# ==============================================================================
# Validação de Limitação de Concorrência do Cargo no Lauda (#47)
# ==============================================================================
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
LAUDA_DOCKERFILE="${1:-$REPO_ROOT/images/lauda/Dockerfile}"

echo "=== [TEST] Validando limitação de concorrência em $LAUDA_DOCKERFILE (#47) ==="

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

echo "=== [MUTATION] Validando sensibilidade a mutantes ==="

# Mutante 1: Ausência de CARGO_BUILD_JOBS
echo -n "-> [MUTAÇÃO 1] Sensibilidade à remoção de CARGO_BUILD_JOBS... "
MUT1_TMP=$(mktemp)
sed '/CARGO_BUILD_JOBS/d' "$LAUDA_DOCKERFILE" > "$MUT1_TMP"
if ! grep -q "ENV CARGO_BUILD_JOBS=1" "$MUT1_TMP"; then
    echo "✅ OK (Mutante 1 detectado e morto)"
else
    echo "❌ FALHOU (Mutante 1 sobreviveu)"
    FAILURES=$((FAILURES + 1))
fi
rm -f "$MUT1_TMP"

# Mutante 2: Remoção do argumento -j 1 do cargo check
echo -n "-> [MUTAÇÃO 2] Sensibilidade à ausência de -j 1 no cargo check... "
MUT2_TMP=$(mktemp)
sed 's/-j 1//g' "$LAUDA_DOCKERFILE" > "$MUT2_TMP"
if ! grep -qE "cargo check.*-j 1" "$MUT2_TMP"; then
    echo "✅ OK (Mutante 2 detectado e morto)"
else
    echo "❌ FALHOU (Mutante 2 sobreviveu)"
    FAILURES=$((FAILURES + 1))
fi
rm -f "$MUT2_TMP"

if [[ $FAILURES -gt 0 ]]; then
    echo ">>> Falhas encontradas na mutação: $FAILURES"
    exit 1
fi

echo ">>> Todos os testes de limitação e mutação passaram com sucesso!"
exit 0
