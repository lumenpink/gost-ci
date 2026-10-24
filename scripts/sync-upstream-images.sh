#!/usr/bin/env bash
# ==============================================================================
# Utilitário Soberano: Espelhamento de Imagens Upstream para gambi.2lp.in (#23)
# ==============================================================================
set -euo pipefail

REGISTRY_HOST="gambi.2lp.in"
REGISTRY_OWNER="lumen"
DRY_RUN=0

# Parse arguments
for arg in "$@"; do
    case "$arg" in
        --dry-run)
            DRY_RUN=1
            ;;
        *)
            echo "Opção desconhecida: $arg" >&2
            echo "Uso: $0 [--dry-run]" >&2
            exit 1
            ;;
    esac
done

# Fail-fast: validação mandatória de credencial
if [[ -z "${GAMBI_2LP_IN_TOKEN:-}" ]]; then
    # Tentar carregar de ~/.env se existir
    if [[ -f "$HOME/.env" ]]; then
        # shellcheck disable=SC1090
        TOKEN_FROM_ENV=$(grep -E '^GAMBI_2LP_IN_TOKEN=' "$HOME/.env" 2>/dev/null | cut -d '=' -f2- | tr -d '"'\'' ')
        if [[ -n "$TOKEN_FROM_ENV" ]]; then
            GAMBI_2LP_IN_TOKEN="$TOKEN_FROM_ENV"
        fi
    fi
fi

if [[ -z "${GAMBI_2LP_IN_TOKEN:-}" ]]; then
    echo "ERRO FATAL [FAIL-FAST]: A variável de ambiente GAMBI_2LP_IN_TOKEN não está definida ou é vazia." >&2
    echo "Configure GAMBI_2LP_IN_TOKEN no ambiente ou em ~/.env antes de prosseguir." >&2
    exit 1
fi

# Matriz Canônica de Imagens Base Upstream e seus Espelhos Soberanos
# Formato: "UPSTREAM_IMAGE|SOVEREIGN_IMAGE_NAME:TAG"
declare -a MIRROR_MATRIX=(
    "node:24-bookworm-slim|mirror-node:24-bookworm-slim"
    "node:24-trixie-slim|mirror-node:24-trixie-slim"
    "debian:bookworm-slim|mirror-debian:bookworm-slim"
    "php:8.4-cli|mirror-php:8.4-cli"
)

echo "=== [GOST-CI] Sincronização de Espelhos de Imagens Upstream (#23) ==="
echo "Registry Soberano: $REGISTRY_HOST/$REGISTRY_OWNER"
echo "Total de imagens mapeadas: ${#MIRROR_MATRIX[@]}"

if [[ "$DRY_RUN" -eq 1 ]]; then
    echo "Modo: DRY-RUN (nenhuma mutação será enviada ao registry)"
fi

# Login no registry do Forgejo
if [[ "$DRY_RUN" -eq 0 ]]; then
    echo "-> Autenticando no registry $REGISTRY_HOST..."
    echo "$GAMBI_2LP_IN_TOKEN" | docker login "$REGISTRY_HOST" -u "$REGISTRY_OWNER" --password-stdin >/dev/null
    echo "OK: Autenticado com sucesso em $REGISTRY_HOST."
fi

# Iterar sobre a matriz
for entry in "${MIRROR_MATRIX[@]}"; do
    upstream="${entry%%|*}"
    target_name="${entry##*|}"
    target="$REGISTRY_HOST/$REGISTRY_OWNER/$target_name"

    echo "-------------------------------------------------------------"
    echo "Upstream: $upstream"
    echo "Destino : $target"

    if [[ "$DRY_RUN" -eq 1 ]]; then
        echo "[DRY-RUN] docker pull $upstream"
        echo "[DRY-RUN] docker tag $upstream $target"
        echo "[DRY-RUN] docker push $target"
    else
        echo "-> Baixando imagem upstream..."
        docker pull "$upstream"

        echo "-> Retagueando para registry soberano..."
        docker tag "$upstream" "$target"

        echo "-> Publicando no registry soberano..."
        docker push "$target"
        echo "OK: $target publicado com sucesso."
    fi
done

echo "============================================================="
echo "SUCESSO: Sincronização de espelhos concluída com êxito!"
exit 0
