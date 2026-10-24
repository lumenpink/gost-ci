#!/usr/bin/env bash
# ==============================================================================
# tests/test-docker-canonical-tags.sh — Auditoria de Tags Canônicas Docker (#19)
# Conforme GOST 1.4.0 e requisitos de reprodutibilidade hermética
# ==============================================================================
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
WORKFLOW="$REPO_ROOT/.forgejo/workflows/build-images.yml"

echo "================================================================="
echo "🧪 [TESTE] Validação de Tags Canônicas nas Imagens Docker (#19)"
echo "================================================================="

FAILURES=0

if [ ! -f "$WORKFLOW" ]; then
    echo "❌ FALHA: Workflow $WORKFLOW não encontrado!"
    exit 1
fi

# Matriz canônica: imagem -> tag de versão esperada (além de :latest)
declare -A CANONICAL_TAGS=(
    ["gost-ci-rust"]="1.99.1"
    ["gost-ci-cross"]="1.99.1"
    ["gost-ci-deploy"]="node24"
    ["gost-ci-wasm"]="1.99.1"
    ["gost-ci-shell"]="0.28.1"
    ["gost-ci-php"]="8.4"
    ["gost-ci-gui"]="1.99.1"
    ["gost-ci-lauda"]="1.99.1"
    ["gost-ci-banca"]="node24"
    ["gost-ci-flutter"]="android34"
    ["gost-ci-android"]="ndk27-sdk34"
)

echo "-> Verificando presença de :latest e tag de versão canônica para as 11 imagens..."

for img in "${!CANONICAL_TAGS[@]}"; do
    expected_ver="${CANONICAL_TAGS[$img]}"
    echo -n "   • $img (esperado: :latest e :$expected_ver)... "

    # 1. Verificar se possui :latest
    has_latest=false
    if grep -q "${img}:latest" "$WORKFLOW"; then
        has_latest=true
    fi

    # 2. Verificar se possui tag canônica de versão
    has_canonical=false
    if grep -q "${img}:${expected_ver}" "$WORKFLOW"; then
        has_canonical=true
    fi

    if [ "$has_latest" = true ] && [ "$has_canonical" = true ]; then
        echo "✅ OK"
    else
        echo "❌ FALHOU (latest=$has_latest, canonical=$has_canonical)"
        FAILURES=$((FAILURES + 1))
    fi
done

# ==============================================================================
# Testes de Mutação — Sensibilidade a Regressões
# ==============================================================================
echo -n "-> [MUTAÇÃO 1] Sensibilidade à ausência de tag canônica em imagem com apenas :latest... "
TMP_WF=$(mktemp)
cat << 'EOF' > "$TMP_WF"
--destination=docker.io/lumenpink/gost-ci-rust:latest
EOF
if ! grep -q "gost-ci-rust:1.99.1" "$TMP_WF"; then
    echo "✅ OK (Detectou ausência da tag 1.99.1)"
else
    echo "❌ FALHOU na mutação 1"
    FAILURES=$((FAILURES + 1))
fi
rm -f "$TMP_WF"

echo -n "-> [MUTAÇÃO 2] Sensibilidade à tag de versão divergente... "
TMP_WF2=$(mktemp)
cat << 'EOF' > "$TMP_WF2"
--destination=docker.io/lumenpink/gost-ci-shell:0.10.0
EOF
if ! grep -q "gost-ci-shell:0.28.1" "$TMP_WF2"; then
    echo "✅ OK (Detectou versão defasada/divergente)"
else
    echo "❌ FALHOU na mutação 2"
    FAILURES=$((FAILURES + 1))
fi
rm -f "$TMP_WF2"

echo "================================================================="
if [ "$FAILURES" -gt 0 ]; then
    echo "💥 $FAILURES IMAGEM(NS) NÃO ATENDEM AOS CRITÉRIOS (Esperado na Fase Red do DD-TDD)."
    exit 1
else
    echo "🎉 TODAS AS 11 IMAGENS DOCKER POSSUEM TAGS CANÔNICAS CONFORMES!"
    exit 0
fi
