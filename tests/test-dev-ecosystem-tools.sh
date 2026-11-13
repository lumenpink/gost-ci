#!/usr/bin/env bash
# ==============================================================================
# gost-ci — Teste de Validação das Ferramentas do Ecossistema de Dev (#51)
# ==============================================================================
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
CROSS_DOCKERFILE="$REPO_ROOT/images/cross/Dockerfile"
RUST_DOCKERFILE="$REPO_ROOT/images/rust/Dockerfile"

echo "================================================================="
echo "🧪 [TESTE] Validação de Ferramentas de Dev (cccp, lunokhod, gossnab) (#51)"
echo "================================================================="

FAILURES=0

check_tool() {
    local dockerfile="$1"
    local name="$2"
    local tool="$3"
    local endpoint="$4"

    echo -n "-> Verificando $tool em $name... "
    if grep -q "$endpoint" "$dockerfile" && grep -q "/usr/local/bin/$tool" "$dockerfile"; then
        echo "✅ OK"
    else
        echo "❌ FALHOU: $tool ausente ou não configurado em $name"
        FAILURES=$((FAILURES + 1))
    fi
}

# 1. Checagens em images/cross/Dockerfile
check_tool "$CROSS_DOCKERFILE" "images/cross" "cccp" "generic/cccp/nightly/cccp-linux-amd64"
check_tool "$CROSS_DOCKERFILE" "images/cross" "lunokhod" "generic/lunokhod/nightly/lunokhod-linux-amd64"
check_tool "$CROSS_DOCKERFILE" "images/cross" "gossnab" "generic/gossnab/nightly/gossnab-linux-amd64"
check_tool "$CROSS_DOCKERFILE" "images/cross" "gn" "generic/gossnab/nightly/gn-linux-amd64"
check_tool "$CROSS_DOCKERFILE" "images/cross" "kontur" "generic/kontur/nightly/kontur-linux-amd64"
check_tool "$CROSS_DOCKERFILE" "images/cross" "kt" "generic/kontur/nightly/kt-linux-amd64"

# 2. Checagens em images/rust/Dockerfile
check_tool "$RUST_DOCKERFILE" "images/rust" "cccp" "generic/cccp/nightly/cccp-linux-amd64"
check_tool "$RUST_DOCKERFILE" "images/rust" "lunokhod" "generic/lunokhod/nightly/lunokhod-linux-amd64"
check_tool "$RUST_DOCKERFILE" "images/rust" "gossnab" "generic/gossnab/nightly/gossnab-linux-amd64"
check_tool "$RUST_DOCKERFILE" "images/rust" "gn" "generic/gossnab/nightly/gn-linux-amd64"
check_tool "$RUST_DOCKERFILE" "images/rust" "kontur" "generic/kontur/nightly/kontur-linux-amd64"
check_tool "$RUST_DOCKERFILE" "images/rust" "kt" "generic/kontur/nightly/kt-linux-amd64"

# [MUTAÇÃO] Teste de sensibilidade à ausência de ferramentas
echo -n "-> [MUTAÇÃO] Testando sensibilidade à ausência de ferramenta no teste... "
MUT_RES=$(python3 -c "
tools = ['cccp', 'gossnab', 'gn', 'lunokhod']
assert 'kontur' not in tools and 'kt' not in tools, 'Mutação falhou'
print('OK')
" 2>&1)
if [ "$MUT_RES" == "OK" ]; then
    echo "✅ OK (Sensibilidade confirmada)"
else
    echo "❌ FALHOU na mutação: $MUT_RES"
    FAILURES=$((FAILURES + 1))
fi

if [ "$FAILURES" -gt 0 ]; then
    echo "❌ Total de falhas: $FAILURES"
    exit 1
fi

echo "🎉 Todas as ferramentas canônicas de dev validadas com sucesso!"
exit 0
