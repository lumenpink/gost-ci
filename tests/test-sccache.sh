#!/usr/bin/env bash
# ==============================================================================
# gost-ci — Teste de Inclusão de sccache nas Imagens com Rust (#20)
# ==============================================================================
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

RUST_DOCKERFILE="$REPO_ROOT/images/rust/Dockerfile"
WASM_DOCKERFILE="$REPO_ROOT/images/wasm/Dockerfile"
CROSS_DOCKERFILE="$REPO_ROOT/images/cross/Dockerfile"
GUI_DOCKERFILE="$REPO_ROOT/images/gui/Dockerfile"

echo "================================================================="
echo "🧪 [TESTE] Validação de sccache em rust, wasm, cross e gui (#20)"
echo "================================================================="

FAILURES=0

for target in "rust:$RUST_DOCKERFILE" "wasm:$WASM_DOCKERFILE" "cross:$CROSS_DOCKERFILE" "gui:$GUI_DOCKERFILE"; do
    NAME="${target%%:*}"
    DOCKERFILE="${target#*:}"
    echo -n "-> Verificando sccache em images/$NAME/Dockerfile... "
    if grep -q "sccache" "$DOCKERFILE" && grep -q "SCCACHE_VERSION" "$DOCKERFILE"; then
        echo "✅ OK"
    else
        echo "❌ FALHOU (sccache ou SCCACHE_VERSION ausente em images/$NAME/Dockerfile)"
        FAILURES=$((FAILURES + 1))
    fi
done

# [MUTAÇÃO] Teste de sensibilidade à ausência de sccache
echo -n "-> [MUTAÇÃO] Testando sensibilidade à ausência de sccache... "
MUT_RES=$(python3 -c "
tools = ['rustc', 'cargo', 'rustfmt', 'clippy']
assert 'sccache' not in tools, 'Mutação falhou: sccache não deveria estar na lista base mutada'
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
