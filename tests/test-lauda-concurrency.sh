#!/usr/bin/env bash
# ==============================================================================
# Validação de Limitação de Concorrência e Binários Canônicos no Lauda (#47, #50)
# ==============================================================================
# Nota: O ticket #50 substituiu a compilação ad-hoc no Lauda pelo consumo direto
# dos binários pré-compilados dos satélites (ishcondidim, papeli, urupema),
# eliminando a necessidade de 'cargo check' e limitações de concorrência.
# ==============================================================================
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
exec "$SCRIPT_DIR/test-lauda-canonical-binaries.sh" "$@"
