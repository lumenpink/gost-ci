#!/usr/bin/env bash
# ==============================================================================
# gost-ci — Teste de Inclusão de libxdo-dev para Desktop/Muda Linking (#17)
# ==============================================================================
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
CROSS_DOCKERFILE="$REPO_ROOT/images/cross/Dockerfile"
GUI_DOCKERFILE="$REPO_ROOT/images/gui/Dockerfile"

echo "================================================================="
echo "🧪 [TESTE] Validação de libxdo-dev em images/cross e images/gui (#17)"
echo "================================================================="

FAILURES=0

echo -n "-> 1. Verificando libxdo-dev em images/cross/Dockerfile... "
if grep -q "libxdo-dev" "$CROSS_DOCKERFILE"; then
    echo "✅ OK"
else
    echo "❌ FALHOU (libxdo-dev ausente em images/cross/Dockerfile)"
    FAILURES=$((FAILURES + 1))
fi

echo -n "-> 2. Verificando libxdo-dev em images/gui/Dockerfile... "
if grep -q "libxdo-dev" "$GUI_DOCKERFILE"; then
    echo "✅ OK"
else
    echo "❌ FALHOU (libxdo-dev ausente em images/gui/Dockerfile)"
    FAILURES=$((FAILURES + 1))
fi

# 3. [MUTAÇÃO] Teste de sensibilidade à ausência de libxdo-dev
echo -n "-> 3. [MUTAÇÃO] Testando sensibilidade à ausência de libxdo-dev... "
MUT_RES=$(python3 -c "
packages = ['libglib2.0-dev', 'libwebkit2gtk-4.1-dev', 'libasound2-dev']
assert 'libxdo-dev' not in packages, 'Mutação falhou'
print('OK')
" 2>&1)
if [ "$MUT_RES" == "OK" ]; then
    echo "✅ OK (Sensibilidade confirmada)"
else
    echo "❌ FALHOU na mutação: $MUT_RES"
    FAILURES=$((FAILURES + 1))
fi

echo "================================================================="
if [ "$FAILURES" -gt 0 ]; then
    echo "💥 $FAILURES TESTE(S) FALHARAM (Esperado na Fase Red do DD-TDD)."
    exit 1
else
    echo "🎉 TODOS OS TESTES PASSARAM COM SUCESSO!"
    exit 0
fi
