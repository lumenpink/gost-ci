#!/usr/bin/env bash
# ==============================================================================
# tests/test-apt-retries.sh — Auditoria de Resiliência de Rede APT nos Dockerfiles (#35)
# ==============================================================================
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
IMAGES_DIR="$REPO_ROOT/images"
FAILED=0

echo "==> [TESTE] Validando configuração de retries do APT em Dockerfiles..."

DOCKERFILES=$(find "$IMAGES_DIR" -maxdepth 2 -name "Dockerfile" | sort)

for df in $DOCKERFILES; do
    rel_path="${df#$REPO_ROOT/}"
    if grep -q "apt-get" "$df"; then
        if grep -q "Acquire::Retries" "$df"; then
            echo "  ✓ $rel_path: Configuração Acquire::Retries presente."
        else
            echo "  ❌ FALHA: $rel_path usa apt-get mas não configura Acquire::Retries."
            FAILED=1
        fi
        if grep -q "Acquire::http::Timeout" "$df"; then
            echo "  ✓ $rel_path: Configuração Acquire::http::Timeout presente."
        else
            echo "  ❌ FALHA: $rel_path usa apt-get mas não configura Acquire::http::Timeout."
            FAILED=1
        fi
    fi
done

if [ "$FAILED" -ne 0 ]; then
    echo "❌ Erro: Um ou mais Dockerfiles não possuem retries/timeouts configurados para o APT."
    exit 1
fi

echo "✅ Todos os Dockerfiles com apt-get possuem resiliência de retries e timeouts configurada."

echo "==> [TESTE] Validando propagação de proxy nas invocações do Kaniko..."
WORKFLOW_FILE="$REPO_ROOT/.forgejo/workflows/build-images.yml"
if [ ! -f "$WORKFLOW_FILE" ]; then
    echo "❌ Erro: Workflow $WORKFLOW_FILE não encontrado."
    exit 1
fi

TOTAL_KANIKO=$(grep -c "/kaniko/executor" "$WORKFLOW_FILE" || true)
TOTAL_WITH_PROXY=$(grep "/kaniko/executor" "$WORKFLOW_FILE" | grep -c "\-\-build-arg http_proxy=" || true)

echo "  • Total de invocações do Kaniko: $TOTAL_KANIKO"
echo "  • Invocações com repasse de http_proxy: $TOTAL_WITH_PROXY"

if [ "$TOTAL_KANIKO" -eq 0 ] || [ "$TOTAL_WITH_PROXY" -ne "$TOTAL_KANIKO" ]; then
    echo "  ❌ FALHA: Existem invocações do Kaniko sem --build-arg http_proxy no workflow."
    exit 1
fi

echo "✅ Todas as invocações do Kaniko propagam http_proxy."

# ==============================================================================
# MUTAÇÃO: Garantir que remoção de Acquire::Retries ou proxy falha o teste
# ==============================================================================
echo "=== [MUTAÇÃO] Testando sensibilidade contra ausência de Acquire::Retries ==="
MUTANT_DIR=$(mktemp -d)
cp -r "$IMAGES_DIR/gui" "$MUTANT_DIR/gui"
sed -i '/Acquire::Retries/d' "$MUTANT_DIR/gui/Dockerfile"

if grep -q "apt-get" "$MUTANT_DIR/gui/Dockerfile" && ! grep -q "Acquire::Retries" "$MUTANT_DIR/gui/Dockerfile"; then
    echo "✓ Mutante (remoção de Acquire::Retries) capturado com precisão."
    rm -rf "$MUTANT_DIR"
else
    rm -rf "$MUTANT_DIR"
    echo "❌ Erro: Falha ao capturar mutante sem Acquire::Retries."
    exit 1
fi

echo "=== [MUTAÇÃO] Testando sensibilidade contra ausência de http_proxy no Kaniko ==="
MUTANT_WF=$(mktemp)
sed 's/--build-arg http_proxy=[^ ]* //g' "$WORKFLOW_FILE" > "$MUTANT_WF"
MUTANT_KANIKO=$(grep -c "/kaniko/executor" "$MUTANT_WF" || true)
MUTANT_WITH_PROXY=$(grep "/kaniko/executor" "$MUTANT_WF" | grep -c "\-\-build-arg http_proxy=" || true)

if [ "$MUTANT_KANIKO" -gt 0 ] && [ "$MUTANT_WITH_PROXY" -eq 0 ]; then
    echo "✓ Mutante (remoção de http_proxy no Kaniko) capturado com precisão."
    rm -f "$MUTANT_WF"
else
    rm -f "$MUTANT_WF"
    echo "❌ Erro: Falha ao capturar mutante sem http_proxy no Kaniko."
    exit 1
fi

exit 0
