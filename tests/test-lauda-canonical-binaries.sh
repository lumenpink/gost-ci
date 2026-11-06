#!/usr/bin/env bash
# ==============================================================================
# Validação de Instalação Canônica dos Binários Satélites no Lauda (#50)
# ==============================================================================
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
LAUDA_DOCKERFILE="${1:-$REPO_ROOT/images/lauda/Dockerfile}"

echo "=== [TEST] Validando consumo de binários pré-compilados em $LAUDA_DOCKERFILE (#50) ==="

FAILURES=0

if [[ ! -f "$LAUDA_DOCKERFILE" ]]; then
    echo "❌ Arquivo $LAUDA_DOCKERFILE não encontrado!"
    exit 1
fi

echo -n "-> 1. Verificando ausência de git clone e cargo check no Lauda... "
if grep -q "git clone" "$LAUDA_DOCKERFILE" || grep -q "cargo check" "$LAUDA_DOCKERFILE"; then
    echo "❌ FALHOU (Compilação ad-hoc ou git clone ainda presentes)"
    FAILURES=$((FAILURES + 1))
else
    echo "✅ OK (Nenhum cargo check ou git clone encontrado)"
fi

echo -n "-> 2. Verificando download canônico de ishcondidim... "
if grep -q "https://gambi.2lp.in/lumen/ishcondidim/releases/download/latest/ishcondidim" "$LAUDA_DOCKERFILE"; then
    echo "✅ OK"
else
    echo "❌ FALHOU (URL canônica do ishcondidim ausente)"
    FAILURES=$((FAILURES + 1))
fi

echo -n "-> 3. Verificando download canônico de papeli... "
if grep -q "https://gambi.2lp.in/lumen/papeli/releases/download/latest/papeli" "$LAUDA_DOCKERFILE"; then
    echo "✅ OK"
else
    echo "❌ FALHOU (URL canônica do papeli ausente)"
    FAILURES=$((FAILURES + 1))
fi

echo -n "-> 4. Verificando download canônico de urupema... "
if grep -q "https://gambi.2lp.in/lumen/urupema/releases/download/latest/urupema" "$LAUDA_DOCKERFILE"; then
    echo "✅ OK"
else
    echo "❌ FALHOU (URL canônica do urupema ausente)"
    FAILURES=$((FAILURES + 1))
fi

echo -n "-> 5. Verificando permissões de execução (chmod +x)... "
if grep -q "chmod +x.*/usr/local/bin/ishcondidim" "$LAUDA_DOCKERFILE" && \
   grep -q "chmod +x.*/usr/local/bin/papeli" "$LAUDA_DOCKERFILE" && \
   grep -q "chmod +x.*/usr/local/bin/urupema" "$LAUDA_DOCKERFILE"; then
    echo "✅ OK"
else
    echo "❌ FALHOU (chmod +x incompleto ou ausente para os satélites)"
    FAILURES=$((FAILURES + 1))
fi

if [[ $FAILURES -gt 0 ]]; then
    echo ">>> Falhas encontradas na validação: $FAILURES"
    exit 1
fi

echo "=== [MUTATION] Validando sensibilidade a mutantes ==="

# Mutante 1: Ausência de ishcondidim
echo -n "-> [MUTAÇÃO 1] Sensibilidade à ausência de ishcondidim... "
MUT1_TMP=$(mktemp)
sed '/ishcondidim/d' "$LAUDA_DOCKERFILE" > "$MUT1_TMP"
if ! grep -q "https://gambi.2lp.in/lumen/ishcondidim/releases/download/latest/ishcondidim" "$MUT1_TMP"; then
    echo "✅ OK (Mutante 1 detectado e morto)"
else
    echo "❌ FALHOU (Mutante 1 sobreviveu)"
    FAILURES=$((FAILURES + 1))
fi
rm -f "$MUT1_TMP"

# Mutante 2: Ausência de papeli
echo -n "-> [MUTAÇÃO 2] Sensibilidade à ausência de papeli... "
MUT2_TMP=$(mktemp)
sed '/papeli/d' "$LAUDA_DOCKERFILE" > "$MUT2_TMP"
if ! grep -q "https://gambi.2lp.in/lumen/papeli/releases/download/latest/papeli" "$MUT2_TMP"; then
    echo "✅ OK (Mutante 2 detectado e morto)"
else
    echo "❌ FALHOU (Mutante 2 sobreviveu)"
    FAILURES=$((FAILURES + 1))
fi
rm -f "$MUT2_TMP"

# Mutante 3: Ausência de urupema
echo -n "-> [MUTAÇÃO 3] Sensibilidade à ausência de urupema... "
MUT3_TMP=$(mktemp)
sed '/urupema/d' "$LAUDA_DOCKERFILE" > "$MUT3_TMP"
if ! grep -q "https://gambi.2lp.in/lumen/urupema/releases/download/latest/urupema" "$MUT3_TMP"; then
    echo "✅ OK (Mutante 3 detectado e morto)"
else
    echo "❌ FALHOU (Mutante 3 sobreviveu)"
    FAILURES=$((FAILURES + 1))
fi
rm -f "$MUT3_TMP"

# Mutante 4: Reintrodução de cargo check
echo -n "-> [MUTAÇÃO 4] Sensibilidade à reintrodução de cargo check... "
MUT4_TMP=$(mktemp)
cp "$LAUDA_DOCKERFILE" "$MUT4_TMP"
echo "RUN cd /tmp && cargo check" >> "$MUT4_TMP"
if grep -q "cargo check" "$MUT4_TMP"; then
    echo "✅ OK (Mutante 4 detectado e morto)"
else
    echo "❌ FALHOU (Mutante 4 sobreviveu)"
    FAILURES=$((FAILURES + 1))
fi
rm -f "$MUT4_TMP"

if [[ $FAILURES -gt 0 ]]; then
    echo ">>> Falhas encontradas na mutação: $FAILURES"
    exit 1
fi

echo ">>> Todos os testes de validação canônica e mutação passaram com sucesso!"
exit 0
