#!/usr/bin/env bash
# ==============================================================================
# tests/test-canonical-packages.sh — Auditoria de Versão Canônica dos Pacotes (#18)
# Conforme GOST 1.4.0 (Seção 4) e SemVer 2.0.0
# ==============================================================================
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

echo "================================================================="
echo "🧪 [TESTE] Validação de Versão Canônica em Workflows de Pacotes (#18)"
echo "================================================================="

FAILURES=0

# Expressão Regular Oficial SemVer 2.0.0
SEMVER_REGEX="^(0|[1-9][0-9]*)\.(0|[1-9][0-9]*)\.(0|[1-9][0-9]*)(-(0|[1-9][0-9]*|[0-9]*[a-zA-Z-][0-9a-zA-Z-]*)(\.(0|[1-9][0-9]*|[0-9]*[a-zA-Z-][0-9a-zA-Z-]*))*)?(\+[0-9a-zA-Z-]+(\.[0-9a-zA-Z-]+)*)?$"

# 1. Validador de SemVer canônico
validate_semver() {
    local ver="$1"
    if [[ "$ver" =~ $SEMVER_REGEX ]]; then
        # Verificar que NÃO contém mais de um caractere '+'
        local plus_count
        plus_count=$(awk -F'+' '{print NF-1}' <<< "$ver")
        if [ "$plus_count" -le 1 ]; then
            return 0
        fi
    fi
    return 1
}

# 2. Teste de conformidade com versões canônicas conhecidas
echo -n "-> Validando formatos SemVer canônicos nominais... "
NOMINAL_CASES=(
    "1.0.0"
    "0.1.0-dev.1"
    "0.1.0-dev.27+20261023.caf0cc7"
    "2.3.4-rc.1+build.12345"
)
for ver in "${NOMINAL_CASES[@]}"; do
    if ! validate_semver "$ver"; then
        echo "❌ FALHOU para versão nominal válida: $ver"
        FAILURES=$((FAILURES + 1))
    fi
done
echo "✅ OK"

# 3. Teste de rejeição de formatos não-canônicos (duplo '+' ou malformados)
echo -n "-> Validando rejeição de duplicidade de metadata e formatos inválidos... "
INVALID_CASES=(
    "0.1.0-dev.27+20261019.caf0cc7+20261023.8f3d610"
    "v1.0.0+meta+extra"
    "01.2.3"
    "1.0"
    "1.0.0+build..invalid"
)
for ver in "${INVALID_CASES[@]}"; do
    if validate_semver "$ver"; then
        echo "❌ FALHOU: Aceitou versão inválida/duplicada: $ver"
        FAILURES=$((FAILURES + 1))
    fi
done
echo "✅ OK"

# 4. Auditoria de Workflows de CI/CD nos repositórios ativos do workspace
echo "-> Auditando derivação de versão nos workflows de empacotamento..."
WORKFLOW_PATHS=(
    /home/lumen/src/ayvu/.forgejo/workflows/ci.yml
    /home/lumen/src/baquara-rs/.forgejo/workflows/ci.yml
    /home/lumen/src/cccp/.forgejo/workflows/ci.yml
    /home/lumen/src/hendu/.forgejo/workflows/ci.yml
    /home/lumen/src/joaju/.forgejo/workflows/ci.yml
    /home/lumen/src/kvant/.forgejo/workflows/ci.yml
    /home/lumen/src/mandu/.forgejo/workflows/ci.yml
    /home/lumen/src/mayak/.forgejo/workflows/ci.yml
    /home/lumen/src/navalha/.forgejo/workflows/ci.yml
    /home/lumen/src/svyaz/.forgejo/workflows/ci.yml
    /home/lumen/src/tuitata/.forgejo/workflows/ci.yml
)

AUDITED_COUNT=0
for wf in "${WORKFLOW_PATHS[@]}"; do
    if [ -f "$wf" ]; then
        AUDITED_COUNT=$((AUDITED_COUNT + 1))
        APP_NAME=$(basename "$(dirname "$(dirname "$(dirname "$wf")")")")
        echo -n "   [audit] $APP_NAME: "

        # Checar se faz concatenação ingênua de BASE_VER sem cut -d'+'
        if grep -q 'BASE_VER=.*head -n 1 VERSION' "$wf"; then
            if ! grep -q 'cut -d.*+.*-f1' "$wf" && ! grep -q 'cut -d '\''+'\'' -f1' "$wf" && ! grep -q 'cut -d"+" -f1' "$wf"; then
                echo "❌ FALHA: Concatenação ingênua sem cut -d'+' -f1 (risco de duplo '+' SemVer)"
                FAILURES=$((FAILURES + 1))
            else
                echo "✅ Conforme"
            fi
        else
            echo "ℹ️  Padrão alternativo ou sem concatenação dinâmica"
        fi
    fi
done

echo "   Total de workflows auditados: $AUDITED_COUNT"

# 5. Testes de Mutação — Sensibilidade a Regressões
echo -n "-> [MUTAÇÃO 1] Testando detecção de string com duplo '+'... "
MUT1_TEST="1.2.3-dev.4+20261020.abc+20261023.def"
if ! validate_semver "$MUT1_TEST"; then
    echo "✅ OK (Mutação capturada com sucesso)"
else
    echo "❌ FALHOU: Mutação não foi detectada!"
    FAILURES=$((FAILURES + 1))
fi

echo -n "-> [MUTAÇÃO 2] Testando sensibilidade a workflow com concatenação sem corte... "
TMP_WF=$(mktemp)
cat << 'EOF' > "$TMP_WF"
BASE_VER=$(head -n 1 VERSION 2>/dev/null | tr -d ' \r\n' || echo "0.1.0-dev")
VERSION="${BASE_VER}+${DATE_STAMP}.${GIT_SHA}"
EOF
if ! grep -q 'cut -d.*+.*-f1' "$TMP_WF" && ! grep -q 'cut -d '\''+'\'' -f1' "$TMP_WF" && ! grep -q 'cut -d"+" -f1' "$TMP_WF"; then
    echo "✅ OK (Padrão defeituoso capturado)"
else
    echo "❌ FALHOU na validação de mutação de workflow"
    FAILURES=$((FAILURES + 1))
fi
rm -f "$TMP_WF"

echo "================================================================="
if [ "$FAILURES" -gt 0 ]; then
    echo "💥 $FAILURES TESTE(S) OU AUDITORIA(S) FALHARAM (Esperado na Fase Red do DD-TDD)."
    exit 1
else
    echo "🎉 TODOS OS WORKFLOWS E TESTES DE VERSÃO CANÔNICA FORAM APROVADOS!"
    exit 0
fi
