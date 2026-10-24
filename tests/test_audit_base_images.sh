#!/usr/bin/env bash
# ==============================================================================
# TESTE: Auditoria de Imagens Base e Espelhamento Soberano (#23)
# ==============================================================================
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SPEC_FILE="$REPO_ROOT/docs/specs/spec-23-mirror-external-images.md"
SYNC_SCRIPT="$REPO_ROOT/scripts/sync-upstream-images.sh"
IMAGES_DIR="$REPO_ROOT/images"

FAILED=0

echo "==> Executando testes de auditoria de imagens base e espelhamento soberano..."

# 1. Validar existência da especificação
if [[ ! -f "$SPEC_FILE" ]]; then
    echo "FALHA: Arquivo de especificação $SPEC_FILE não encontrado."
    FAILED=1
else
    echo "OK: Especificação de espelhamento presente."
fi

# 2. Validar existência e executabilidade do script de sincronização
if [[ ! -f "$SYNC_SCRIPT" ]]; then
    echo "FALHA: Script de sincronização $SYNC_SCRIPT não encontrado."
    FAILED=1
elif [[ ! -x "$SYNC_SCRIPT" ]]; then
    echo "FALHA: Script $SYNC_SCRIPT não possui permissão de execução."
    FAILED=1
else
    echo "OK: Script de sincronização existe e é executável."

    # 3. Validar fail-fast do script na ausência de GAMBI_2LP_IN_TOKEN
    echo -n "-> Testando fail-fast de GAMBI_2LP_IN_TOKEN... "
    TMP_EMPTY_HOME=$(mktemp -d)
    if HOME="$TMP_EMPTY_HOME" env -u GAMBI_2LP_IN_TOKEN bash "$SYNC_SCRIPT" --dry-run >/dev/null 2>&1; then
        rm -rf "$TMP_EMPTY_HOME"
        echo "FALHA: Script não abortou na ausência de GAMBI_2LP_IN_TOKEN."
        FAILED=1
    else
        rm -rf "$TMP_EMPTY_HOME"
        echo "OK: Script aborta com erro quando token não é fornecido."
    fi
fi

# 4. Validar se todos os Dockerfiles em images/ usam o registry soberano gambi.2lp.in
echo "-> Auditando instruções FROM em $IMAGES_DIR..."
DOCKERFILES=$(find "$IMAGES_DIR" -maxdepth 2 -name "Dockerfile")

if [[ -z "$DOCKERFILES" ]]; then
    echo "FALHA: Nenhum Dockerfile encontrado em $IMAGES_DIR."
    FAILED=1
fi

for df in $DOCKERFILES; do
    rel_path="${df#$REPO_ROOT/}"
    # Extrair linhas FROM (ignorando comentários)
    while IFS= read -r line; do
        if [[ "$line" =~ ^[[:space:]]*FROM[[:space:]]+([^[:space:]]+) ]]; then
            base_image="${BASH_REMATCH[1]}"
            if [[ ! "$base_image" =~ ^gambi\.2lp\.in/lumen/ ]]; then
                echo "FALHA [$rel_path]: FROM referencia imagem externa '$base_image' (deve usar gambi.2lp.in/lumen/*)."
                FAILED=1
            else
                echo "OK [$rel_path]: $base_image"
            fi
        fi
    done < <(grep -E '^[[:space:]]*FROM[[:space:]]+' "$df" || true)
done

# 5. Validar que o script de sincronização lista a matriz canônica completa
if [[ -f "$SYNC_SCRIPT" ]]; then
    REQUIRED_BASES=("node:24-bookworm-slim" "node:24-trixie-slim" "debian:bookworm-slim" "php:8.4-cli")
    for base in "${REQUIRED_BASES[@]}"; do
        if ! grep -q "$base" "$SYNC_SCRIPT"; then
            echo "FALHA: Imagem base obrigatória '$base' não listada em $SYNC_SCRIPT."
            FAILED=1
        fi
    done
fi

echo "================================================================="
if [[ "$FAILED" -eq 0 ]]; then
    echo "SUCESSO: Todas as imagens Docker utilizam espelhos canônicos soberanos!"
    exit 0
else
    echo "STATUS: RED (Requisitos pendentes de implementação)"
    exit 1
fi
