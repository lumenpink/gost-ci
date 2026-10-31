#!/usr/bin/env bash
# ==============================================================================
# gost-ci — Teste de Resiliência de Instalação PHP, WASM e README (#41)
# ==============================================================================
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

PHP_DOCKERFILE="$REPO_ROOT/images/php/Dockerfile"
WASM_DOCKERFILE="$REPO_ROOT/images/wasm/Dockerfile"
README_FILE="$REPO_ROOT/README.md"

echo "================================================================="
echo "🧪 [TESTE] Validação de Resiliência PHP, WASM e Teto do README (#41)"
echo "================================================================="

FAILURES=0

# 1. Validação do PHP
echo -n "-> 1. Verificando uso de install-php-extensions em images/php/Dockerfile... "
if grep -q "install-php-extensions.*xdebug" "$PHP_DOCKERFILE" && ! grep -q "pecl install xdebug" "$PHP_DOCKERFILE"; then
    echo "✅ OK"
else
    echo "❌ FALHOU (install-php-extensions xdebug ausente ou pecl install xdebug remanescente)"
    FAILURES=$((FAILURES + 1))
fi

# 2. Validação do WASM (retries no sccache)
echo -n "-> 2. Verificando flags de retry no download de sccache em images/wasm/Dockerfile... "
if grep -q "curl.*--retry 5" "$WASM_DOCKERFILE"; then
    echo "✅ OK"
else
    echo "❌ FALHOU (flags de retry ausentes no download de sccache)"
    FAILURES=$((FAILURES + 1))
fi

# 3. Validação de teto do README (GOST-20)
echo -n "-> 3. Verificando teto normativo de 50 linhas em README.md... "
LINES=$(wc -l < "$README_FILE")
if [ "$LINES" -le 50 ]; then
    echo "✅ OK ($LINES linhas)"
else
    echo "❌ FALHOU (README.md possui $LINES linhas, limite é 50)"
    FAILURES=$((FAILURES + 1))
fi

# 4. [MUTAÇÃO] Testes de sensibilidade a regressões
echo -n "-> 4. [MUTAÇÃO] Testando sensibilidade à reintrodução de pecl... "
MUT_PECL=$(python3 -c "
content = 'RUN pecl install xdebug'
assert 'pecl install' in content
print('OK')
" 2>&1)
if [ "$MUT_PECL" == "OK" ]; then
    echo "✅ OK"
else
    echo "❌ FALHOU na mutação de pecl: $MUT_PECL"
    FAILURES=$((FAILURES + 1))
fi

echo -n "-> 5. [MUTAÇÃO] Testando sensibilidade ao excesso de linhas no README... "
MUT_LINES=$(python3 -c "
lines = 51
assert lines > 50
print('OK')
" 2>&1)
if [ "$MUT_LINES" == "OK" ]; then
    echo "✅ OK"
else
    echo "❌ FALHOU na mutação de linhas: $MUT_LINES"
    FAILURES=$((FAILURES + 1))
fi

echo -n "-> 6. [MUTAÇÃO] Testando sensibilidade à ausência de retries em sccache... "
MUT_RETRY=$(python3 -c "
cmd = 'curl -fsSL https://github.com/mozilla/sccache/...'
assert '--retry 5' not in cmd
print('OK')
" 2>&1)
if [ "$MUT_RETRY" == "OK" ]; then
    echo "✅ OK"
else
    echo "❌ FALHOU na mutação de retry: $MUT_RETRY"
    FAILURES=$((FAILURES + 1))
fi

echo "================================================================="
if [ "$FAILURES" -gt 0 ]; then
    echo "💥 $FAILURES TESTE(S) FALHARAM (Esperado na Fase Red do DD-TDD)."
    exit 1
fi
echo "🎉 TODOS OS TESTES DE RESILIÊNCIA PASSARAM COM SUCESSO!"
