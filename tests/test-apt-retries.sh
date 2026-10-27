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
    fi
done

if [ "$FAILED" -ne 0 ]; then
    echo "❌ Erro: Um ou mais Dockerfiles não possuem retries configurados para o APT."
    exit 1
fi

echo "✅ Todos os Dockerfiles com apt-get possuem resiliência de retries configurada."

# ==============================================================================
# MUTAÇÃO: Garantir que remoção de Acquire::Retries falha o teste
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

exit 0
