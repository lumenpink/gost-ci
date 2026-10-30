#!/usr/bin/env bash
# ==============================================================================
# TESTE: Auditoria de Isolamento de Espelhos PHP e Dioxus (#40)
# ==============================================================================
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SPEC_FILE="$REPO_ROOT/docs/specs/spec-40-isolar-espelhos-php-dioxus.md"
SYNC_SCRIPT="$REPO_ROOT/scripts/sync-upstream-images.sh"
PHP_DF="$REPO_ROOT/images/php/Dockerfile"
WASM_DF="$REPO_ROOT/images/wasm/Dockerfile"
ANDROID_DF="$REPO_ROOT/images/android/Dockerfile"

FAILED=0

echo "==> Executando testes de isolamento de espelhos PHP e Dioxus (#40)..."

# 1. Validar existência da especificação
if [[ ! -f "$SPEC_FILE" ]]; then
    echo "FALHA: Arquivo de especificação $SPEC_FILE não encontrado."
    FAILED=1
else
    echo "OK: Especificação #40 presente."
fi

# 2. Validar que scripts/sync-upstream-images.sh inclui composer e php-extension-installer
echo -n "-> Verificando espelhos adicionais em $SYNC_SCRIPT... "
if grep -q "composer:2|mirror-composer:2" "$SYNC_SCRIPT" && grep -q "mlocati/php-extension-installer|mirror-php-extension-installer:latest" "$SYNC_SCRIPT"; then
    echo "OK: Espelhos de composer e php-extension-installer configurados no script."
else
    echo "FALHA: $SYNC_SCRIPT não possui composer:2 ou mlocati/php-extension-installer mapeados."
    FAILED=1
fi

# 3. Validar que images/php/Dockerfile não possui COPY --from com imagens externas
echo -n "-> Auditando COPY --from em $PHP_DF... "
EXTERNAL_COPY=0
while IFS= read -r line; do
    if [[ "$line" =~ ^[[:space:]]*COPY[[:space:]]+--from=([^[:space:]]+) ]]; then
        copy_img="${BASH_REMATCH[1]}"
        # Se for um estágio numérico ou nome de estágio local, ok; se for imagem externa, deve vir de gambi.2lp.in
        if [[ ! "$copy_img" =~ ^gambi\.2lp\.in/lumen/mirror- ]]; then
            echo "FALHA: COPY --from referencia imagem externa não espelhada: '$copy_img'"
            EXTERNAL_COPY=1
            FAILED=1
        fi
    fi
done < <(grep -E '^[[:space:]]*COPY[[:space:]]+--from=' "$PHP_DF" || true)

if [[ "$EXTERNAL_COPY" -eq 0 ]]; then
    echo "OK: Todas as imagens multi-stage em $PHP_DF usam o mirror local."
fi

# 4. Validar que images/wasm/Dockerfile consome Dioxus via Generic Package local
echo -n "-> Verificando Dioxus dx em $WASM_DF... "
if grep -q "gambi\.2lp\.in/api/packages/lumen/generic/dioxus" "$WASM_DF" && ! grep -q "github\.com/DioxusLabs/dioxus" "$WASM_DF"; then
    echo "OK: Dioxus dx consome Generic Package local em wasm."
else
    echo "FALHA: $WASM_DF ainda consome Dioxus de github.com ou não usa Generic Package local."
    FAILED=1
fi

# 5. Validar que images/android/Dockerfile consome Dioxus via Generic Package local
echo -n "-> Verificando Dioxus dx em $ANDROID_DF... "
if grep -q "gambi\.2lp\.in/api/packages/lumen/generic/dioxus" "$ANDROID_DF" && ! grep -q "github\.com/DioxusLabs/dioxus" "$ANDROID_DF"; then
    echo "OK: Dioxus dx consome Generic Package local em android."
else
    echo "FALHA: $ANDROID_DF ainda consome Dioxus de github.com ou não usa Generic Package local."
    FAILED=1
fi

if [[ "$FAILED" -ne 0 ]]; then
    echo "==> RESULTADO: FALHA (Contrato ainda não implementado)"
    exit 1
fi

echo "==> RESULTADO: SUCESSO (Todos os requisitos atendidos)"
exit 0
