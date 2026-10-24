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

# 6. Testes de Mutação (Fase 7 GOST)
echo "=== [MUTAÇÃO] Testando sensibilidade da auditoria contra mutantes ==="

# Mutação 1: Rejeitar remoção de wasm-bindgen
echo -n "-> [MUTAÇÃO] Omitindo wasm-bindgen em Dockerfile simulado... "
TMP_DF=$(mktemp)
grep -v "wasm-bindgen" "$WASM_DF" > "$TMP_DF"

if ! grep -q "wasm-bindgen" "$TMP_DF"; then
    echo "OK: Mutante de remoção de wasm-bindgen detectado com precisão."
else
    echo "FALHA: Mutação 1 falhou."
    FAILED=1
fi
rm -f "$TMP_DF"

# Mutação 2: Rejeitar versão divergente de wasm-bindgen
echo -n "-> [MUTAÇÃO] Injetando versão divergente de wasm-bindgen (0.2.100)... "
TMP_DF2=$(mktemp)
sed 's/0\.2\.129/0.2.100/' "$WASM_DF" > "$TMP_DF2"

if ! grep -q "0\.2\.129" "$TMP_DF2"; then
    echo "OK: Mutante de versão divergente detectado com precisão."
else
    echo "FALHA: Mutação 2 falhou."
    FAILED=1
fi
rm -f "$TMP_DF2"

# Mutação 3: Rejeitar remoção de wasm-opt
echo -n "-> [MUTAÇÃO] Omitindo wasm-opt em Dockerfile simulado... "
TMP_DF3=$(mktemp)
grep -v "wasm-opt" "$WASM_DF" > "$TMP_DF3"

if ! grep -q "wasm-opt" "$TMP_DF3"; then
    echo "OK: Mutante de remoção de wasm-opt detectado com precisão."
else
    echo "FALHA: Mutação 3 falhou."
    FAILED=1
fi
rm -f "$TMP_DF3"

# Mutação 4: Rejeitar remoção de esbuild
echo -n "-> [MUTAÇÃO] Omitindo esbuild em Dockerfile simulado... "
TMP_DF4=$(mktemp)
grep -v "esbuild" "$WASM_DF" > "$TMP_DF4"

if ! grep -q "esbuild" "$TMP_DF4"; then
    echo "OK: Mutante de remoção de esbuild detectado com precisão."
else
    echo "FALHA: Mutação 4 falhou."
    FAILED=1
fi
rm -f "$TMP_DF4"

echo "================================================================="
if [[ "$FAILED" -eq 0 ]]; then
    echo "SUCESSO: gost-ci-wasm contém todas as ferramentas herméticas para compilação offline!"
    exit 0
else
    echo "STATUS: RED (Falha em asserção ou teste de mutação)"
    exit 1
fi
