#!/usr/bin/env bash
# ==============================================================================
# TESTE: Auditoria de Hermeticidade de gost-ci-wasm (#22)
# ==============================================================================
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SPEC="$REPO_ROOT/docs/specs/spec-22-hermetic-wasm-cross.md"
WASM_DF="$REPO_ROOT/images/wasm/Dockerfile"

FAILED=0

echo "==> Executando testes de auditoria de hermeticidade de gost-ci-wasm..."

# 1. Validar existência da especificação
if [[ ! -f "$SPEC" ]]; then
    echo "FALHA: Arquivo de especificação $SPEC não encontrado."
    FAILED=1
else
    echo "OK: Especificação de hermeticidade presente."
fi

# 2. Validar existência de images/wasm/Dockerfile
if [[ ! -f "$WASM_DF" ]]; then
    echo "FALHA: Dockerfile $WASM_DF não encontrado."
    FAILED=1
else
    echo "OK: Dockerfile images/wasm/Dockerfile existe."
fi

# 3. Validar inclusão explícita de wasm-bindgen-cli na versão 0.2.129
echo -n "-> Verificando wasm-bindgen-cli v0.2.129 em images/wasm/Dockerfile... "
if grep -q "wasm-bindgen" "$WASM_DF" && grep -q "0\.2\.129" "$WASM_DF"; then
    echo "OK: wasm-bindgen-cli 0.2.129 declarado no Dockerfile."
else
    echo "FALHA: wasm-bindgen-cli 0.2.129 ausente em $WASM_DF."
    FAILED=1
fi

# 4. Validar inclusão explícita de wasm-opt (Binaryen)
echo -n "-> Verificando utilitário wasm-opt em images/wasm/Dockerfile... "
if grep -q "wasm-opt" "$WASM_DF"; then
    echo "OK: wasm-opt declarado no Dockerfile."
else
    echo "FALHA: wasm-opt ausente em $WASM_DF."
    FAILED=1
fi

# 5. Validar inclusão explícita de esbuild
echo -n "-> Verificando utilitário esbuild em images/wasm/Dockerfile... "
if grep -q "esbuild" "$WASM_DF"; then
    echo "OK: esbuild declarado no Dockerfile."
else
    echo "FALHA: esbuild ausente em $WASM_DF."
    FAILED=1
fi

echo "================================================================="
if [[ "$FAILED" -eq 0 ]]; then
    echo "SUCESSO: gost-ci-wasm contém todas as ferramentas herméticas para compilação offline!"
    exit 0
else
    echo "STATUS: RED (Ferramentas herméticas pendentes de inclusão)"
    exit 1
fi
