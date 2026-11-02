#!/usr/bin/env bash
# ==============================================================================
# Validação do Escalonamento em Ondas da Esteira (#48)
# ==============================================================================
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
WORKFLOW_FILE="${1:-$REPO_ROOT/.forgejo/workflows/build-images.yml}"

echo "=== [TEST] Validando escalonamento em ondas em $WORKFLOW_FILE (#48) ==="

FAILURES=0

if [[ ! -f "$WORKFLOW_FILE" ]]; then
    echo "❌ Arquivo $WORKFLOW_FILE não encontrado!"
    exit 1
fi

# 1. Validação de Onda 2 (build-deploy, build-wasm, build-gui, build-android, build-lauda)
echo -n "-> 1. Verificando dependências needs na Onda 2... "
if grep -q "needs:.*build-rust" "$WORKFLOW_FILE" && \
   grep -B 3 -A 6 "build-deploy:" "$WORKFLOW_FILE" | grep -q "needs:" && \
   grep -B 3 -A 6 "build-wasm:" "$WORKFLOW_FILE" | grep -q "needs:" && \
   grep -B 3 -A 6 "build-gui:" "$WORKFLOW_FILE" | grep -q "needs:" && \
   grep -B 3 -A 6 "build-android:" "$WORKFLOW_FILE" | grep -q "needs:"; then
    echo "✅ OK"
else
    echo "❌ FALHOU (Faltam declarações needs na Onda 2)"
    FAILURES=$((FAILURES + 1))
fi

# 2. Validação de Onda 3 (build-banca, build-cross, build-flutter)
echo -n "-> 2. Verificando dependências needs na Onda 3... "
if grep -B 3 -A 6 "build-banca:" "$WORKFLOW_FILE" | grep -q "needs:" && \
   grep -B 3 -A 6 "build-cross:" "$WORKFLOW_FILE" | grep -q "needs:" && \
   grep -B 3 -A 6 "build-flutter:" "$WORKFLOW_FILE" | grep -q "needs:"; then
    echo "✅ OK"
else
    echo "❌ FALHOU (Faltam declarações needs na Onda 3)"
    FAILURES=$((FAILURES + 1))
fi

# 3. Validação da cláusula if resiliente nos jobs dependentes
echo -n "-> 3. Verificando if: always() && !cancelled() nos jobs escalonados... "
NON_CANCELLED_COUNT=$(grep -c "always() && !cancelled()" "$WORKFLOW_FILE" || true)
if [[ $NON_CANCELLED_COUNT -ge 7 ]]; then
    echo "✅ OK (Encontradas $NON_CANCELLED_COUNT cláusulas)"
else
    echo "❌ FALHOU (Encontradas apenas $NON_CANCELLED_COUNT cláusulas if resilientes; esperado >= 7)"
    FAILURES=$((FAILURES + 1))
fi

if [[ $FAILURES -gt 0 ]]; then
    echo ">>> Falhas encontradas: $FAILURES"
    exit 1
fi

echo "=== [MUTATION] Validando sensibilidade a mutantes ==="

# Mutante 1: Ausência de needs em build-banca
echo -n "-> [MUTAÇÃO 1] Sensibilidade à ausência de needs em build-banca... "
MUT1_TMP=$(mktemp)
sed '/build-banca:/,/steps:/ s/needs:.*//' "$WORKFLOW_FILE" > "$MUT1_TMP"
if ! (grep -B 3 -A 6 "build-banca:" "$MUT1_TMP" | grep -q "needs:"); then
    echo "✅ OK (Mutante 1 detectado e morto)"
else
    echo "❌ FALHOU (Mutante 1 sobreviveu)"
    FAILURES=$((FAILURES + 1))
fi
rm -f "$MUT1_TMP"

# Mutante 2: Ausência de cláusula if resiliente
echo -n "-> [MUTAÇÃO 2] Sensibilidade à ausência de if: always() && !cancelled()... "
MUT2_TMP=$(mktemp)
sed 's/always() && !cancelled()/true/' "$WORKFLOW_FILE" > "$MUT2_TMP"
COUNT_MUT=$(grep -c "always() && !cancelled()" "$MUT2_TMP" || true)
if [[ $COUNT_MUT -lt 7 ]]; then
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

echo ">>> Todos os testes de escalonamento e mutação passaram com sucesso!"
exit 0
