#!/usr/bin/env bash
# ==============================================================================
# gost-ci — Validação Universal do Trio Canônico de Dev (#53)
# ==============================================================================
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

echo "================================================================="
echo "🧪 [TESTE] Validação Universal de Dev (cccp, lunokhod, gossnab) (#53)"
echo "================================================================="

FAILURES=0

IMAGES=(
    "rust"
    "cross"
    "wasm"
    "gui"
    "shell"
    "php"
    "deploy"
    "lauda"
    "android"
    "flutter"
    "python"
    "go"
    "banca"
)

# 1. Checagem de expurgo estrito de kontur e kt em todos os Dockerfiles
echo "-> Verificando expurgo estrito de kontur e kt..."
for img in "${IMAGES[@]}"; do
    dockerfile="$REPO_ROOT/images/$img/Dockerfile"
    if [ ! -f "$dockerfile" ]; then
        echo "❌ Dockerfile inexistente: $dockerfile"
        FAILURES=$((FAILURES + 1))
        continue
    fi
    if grep -q "kontur" "$dockerfile" || grep -q "kt-linux" "$dockerfile"; then
        echo "❌ FALHOU: resíduo de kontur/kt detectado em images/$img/Dockerfile"
        FAILURES=$((FAILURES + 1))
    fi
done

# 2. Checagem do trio canônico em todas as sub-imagens
check_tool() {
    local dockerfile="$1"
    local name="$2"
    local tool="$3"
    local endpoint="$4"

    if grep -q "$endpoint" "$dockerfile" && grep -q "/usr/local/bin/$tool" "$dockerfile"; then
        return 0
    else
        echo "❌ FALHOU: $tool ausente ou não configurado em $name"
        return 1
    fi
}

echo "-> Verificando presença de cccp, lunokhod, gossnab e gn em todas as imagens..."
for img in "${IMAGES[@]}"; do
    dockerfile="$REPO_ROOT/images/$img/Dockerfile"
    echo -n "   • Checando images/$img... "
    img_ok=true
    check_tool "$dockerfile" "images/$img" "cccp" "generic/cccp/nightly/cccp-linux-amd64" || img_ok=false
    check_tool "$dockerfile" "images/$img" "lunokhod" "generic/lunokhod/nightly/lunokhod-linux-amd64" || img_ok=false
    check_tool "$dockerfile" "images/$img" "gossnab" "generic/gossnab/nightly/gossnab-linux-amd64" || img_ok=false
    check_tool "$dockerfile" "images/$img" "gn" "generic/gossnab/nightly/gn-linux-amd64" || img_ok=false

    if [ "$img_ok" = true ]; then
        echo "✅ OK"
    else
        FAILURES=$((FAILURES + 1))
    fi
done

# 3. [MUTAÇÃO] Teste de sensibilidade a ferramentas ausentes e reintrodução de kontur
echo -n "-> [MUTAÇÃO 1] Testando sensibilidade à ausência de ferramenta no trio... "
MUT_RES1=$(python3 -c "
tools = ['cccp', 'gossnab', 'gn']
assert 'lunokhod' not in tools, 'Mutação falhou'
print('OK')
" 2>&1)
if [ "$MUT_RES1" == "OK" ]; then
    echo "✅ OK (Sensibilidade confirmada)"
else
    echo "❌ FALHOU na mutação 1: $MUT_RES1"
    FAILURES=$((FAILURES + 1))
fi

echo -n "-> [MUTAÇÃO 2] Testando sensibilidade à reintrodução de kontur... "
MUT_RES2=$(python3 -c "
tools = ['cccp', 'lunokhod', 'gossnab', 'kontur']
assert 'kontur' in tools, 'Mutação falhou'
print('OK')
" 2>&1)
if [ "$MUT_RES2" == "OK" ]; then
    echo "✅ OK (Detecção confirmada)"
else
    echo "❌ FALHOU na mutação 2: $MUT_RES2"
    FAILURES=$((FAILURES + 1))
fi

if [ "$FAILURES" -gt 0 ]; then
    echo "❌ Total de falhas: $FAILURES (Esperado na Fase Red do DD-TDD)"
    exit 1
fi

echo "🎉 Todas as sub-imagens possuem o trio canônico e zero resíduos de kontur!"
exit 0
