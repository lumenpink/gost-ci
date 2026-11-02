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
        if grep -q "Acquire::http::Retries" "$df"; then
            echo "  ✓ $rel_path: Configuração Acquire::http::Retries presente."
        else
            echo "  ❌ FALHA: $rel_path usa apt-get mas não configura Acquire::http::Retries."
            FAILED=1
        fi
        if grep -qE "\(apt-get update \|\|" "$df"; then
            echo "  ✓ $rel_path: Fallback/retry em apt-get update presente."
        else
            echo "  ❌ FALHA: $rel_path usa apt-get mas não configura fallback em apt-get update."
            FAILED=1
        fi
        if grep -q "Acquire::http::Proxy" "$df" && grep -q "rm -f /etc/apt/apt.conf.d/01proxy" "$df"; then
            echo "  ✓ $rel_path: Configuração de proxy dinâmico 01proxy presente e com limpeza."
        else
            echo "  ❌ FALHA: $rel_path usa apt-get mas não configura injeção/limpeza de 01proxy."
            FAILED=1
        fi
    fi
done

if [ "$FAILED" -ne 0 ]; then
    echo "❌ Erro: Um ou mais Dockerfiles não possuem retries/timeouts/01proxy configurados para o APT."
    exit 1
fi

echo "✅ Todos os Dockerfiles com apt-get possuem resiliência de retries, timeouts e proxy configurada."

echo "==> [TESTE] Validando propagação de proxy nas invocações do Kaniko..."
WORKFLOW_FILE="$REPO_ROOT/.forgejo/workflows/build-images.yml"
if [ ! -f "$WORKFLOW_FILE" ]; then
    echo "❌ Erro: Workflow $WORKFLOW_FILE não encontrado."
    exit 1
fi

if ! grep -q "172.17.0.1:3142" "$WORKFLOW_FILE"; then
    echo "  ❌ FALHA: Workflow não possui IP de proxy explícito 172.17.0.1:3142."
    exit 1
fi

TOTAL_KANIKO=$(grep -c "/kaniko/executor" "$WORKFLOW_FILE" || true)
TOTAL_WITH_PROXY=$(grep "/kaniko/executor" "$WORKFLOW_FILE" | grep -c "\-\-build-arg http_proxy=\"http://172.17.0.1:3142\"" || true)

echo "  • Total de invocações do Kaniko: $TOTAL_KANIKO"
echo "  • Invocações com repasse explícito de proxy 172.17.0.1:3142: $TOTAL_WITH_PROXY"

if [ "$TOTAL_KANIKO" -eq 0 ] || [ "$TOTAL_WITH_PROXY" -ne "$TOTAL_KANIKO" ]; then
    echo "  ❌ FALHA: Existem invocações do Kaniko sem proxy explícito 172.17.0.1:3142 no workflow."
    exit 1
fi

echo "✅ Todas as invocações do Kaniko propagam proxy 172.17.0.1:3142 explicitamente."

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

echo "=== [MUTAÇÃO] Testando sensibilidade contra ausência de Acquire::http::Timeout ==="
MUTANT_TIMEOUT_DIR=$(mktemp -d)
cp -r "$IMAGES_DIR/rust" "$MUTANT_TIMEOUT_DIR/rust"
sed -i '/Acquire::http::Timeout/d' "$MUTANT_TIMEOUT_DIR/rust/Dockerfile"

if grep -q "apt-get" "$MUTANT_TIMEOUT_DIR/rust/Dockerfile" && ! grep -q "Acquire::http::Timeout" "$MUTANT_TIMEOUT_DIR/rust/Dockerfile"; then
    echo "✓ Mutante (remoção de Acquire::http::Timeout) capturado com precisão."
    rm -rf "$MUTANT_TIMEOUT_DIR"
else
    rm -rf "$MUTANT_TIMEOUT_DIR"
    echo "❌ Erro: Falha ao capturar mutante sem Acquire::http::Timeout."
    exit 1
fi

echo "=== [MUTAÇÃO] Testando sensibilidade contra ausência de 01proxy no Dockerfile ==="
MUTANT_01PROXY_DIR=$(mktemp -d)
cp -r "$IMAGES_DIR/wasm" "$MUTANT_01PROXY_DIR/wasm"
sed -i '/01proxy/d' "$MUTANT_01PROXY_DIR/wasm/Dockerfile"

if grep -q "apt-get" "$MUTANT_01PROXY_DIR/wasm/Dockerfile" && ! grep -q "01proxy" "$MUTANT_01PROXY_DIR/wasm/Dockerfile"; then
    echo "✓ Mutante (remoção de 01proxy) capturado com precisão."
    rm -rf "$MUTANT_01PROXY_DIR"
else
    rm -rf "$MUTANT_01PROXY_DIR"
    echo "❌ Erro: Falha ao capturar mutante sem 01proxy."
    exit 1
fi

echo "=== [MUTAÇÃO] Testando sensibilidade contra ausência de http_proxy no Kaniko ==="
MUTANT_WF=$(mktemp)
sed 's/--build-arg http_proxy=[^ ]* //g' "$WORKFLOW_FILE" > "$MUTANT_WF"
MUTANT_KANIKO=$(grep -c "/kaniko/executor" "$MUTANT_WF" || true)
MUTANT_WITH_PROXY=$(grep "/kaniko/executor" "$MUTANT_WF" | grep -c "\-\-build-arg http_proxy=\"http://172.17.0.1:3142\"" || true)

if [ "$MUTANT_KANIKO" -gt 0 ] && [ "$MUTANT_WITH_PROXY" -eq 0 ]; then
    echo "✓ Mutante (remoção de http_proxy no Kaniko) capturado com precisão."
    rm -f "$MUTANT_WF"
else
    rm -f "$MUTANT_WF"
    echo "❌ Erro: Falha ao capturar mutante sem http_proxy no Kaniko."
    exit 1
fi

exit 0
