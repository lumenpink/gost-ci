#!/usr/bin/env bash
# ==============================================================================
# TESTE: Publicação Exclusiva no Registry Soberano gambi.2lp.in (#21)
# ==============================================================================
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
WORKFLOW="$REPO_ROOT/.forgejo/workflows/build-images.yml"
SPEC="$REPO_ROOT/docs/specs/spec-21-kaniko-registry-gambi.md"
README="$REPO_ROOT/README.md"

FAILED=0

echo "==> Executando testes de auditoria da esteira soberana gambi.2lp.in..."

# 1. Validar existência da especificação
if [[ ! -f "$SPEC" ]]; then
    echo "FALHA: Arquivo de especificação $SPEC não encontrado."
    FAILED=1
else
    echo "OK: Especificação do registry soberano presente."
fi

# 2. Proibição estrita de Docker Hub e credenciais legadas no workflow
echo -n "-> Verificando ausência de referências a docker.io e secrets DockerHub... "
if grep -q "docker.io" "$WORKFLOW" || grep -q "DOCKERHUB" "$WORKFLOW"; then
    echo "FALHA: Referências a docker.io ou DOCKERHUB encontradas em $WORKFLOW."
    FAILED=1
else
    echo "OK: Docker Hub totalmente removido do workflow."
fi

# 3. Proibição de URL absoluta no checkout do Forgejo
echo -n "-> Verificando sintaxe compatível de checkout actions/checkout@v4... "
if grep -q "https://github.com/actions/checkout" "$WORKFLOW"; then
    echo "FALHA: Encontrado 'https://github.com/actions/checkout' no workflow (Forgejo requer 'actions/checkout@v4')."
    FAILED=1
else
    echo "OK: Sintaxe de checkout compatível com Forgejo Actions."
fi

# 4. Validar autenticação e fail-fast com GAMBI_2LP_IN_TOKEN
echo -n "-> Verificando autenticação no registry gambi.2lp.in e fail-fast de token... "
if ! grep -q "gambi.2lp.in" "$WORKFLOW" || ! grep -q "GAMBI_2LP_IN_TOKEN" "$WORKFLOW"; then
    echo "FALHA: Endpoint gambi.2lp.in ou secret GAMBI_2LP_IN_TOKEN ausente em $WORKFLOW."
    FAILED=1
elif ! grep -q "FAIL-FAST" "$WORKFLOW"; then
    echo "FALHA: Mecanismo de fail-fast para GAMBI_2LP_IN_TOKEN ausente em $WORKFLOW."
    FAILED=1
else
    echo "OK: Autenticação soberana e fail-fast presentes."
fi

# 5. Validar que todas as 10 imagens apontam para gambi.2lp.in/lumen/*
IMAGES=(
    "gost-ci-rust"
    "gost-ci-cross"
    "gost-ci-deploy"
    "gost-ci-wasm"
    "gost-ci-shell"
    "gost-ci-php"
    "gost-ci-gui"
    "gost-ci-lauda"
    "gost-ci-banca"
    "gost-ci-flutter"
)

echo "-> Verificando destinos no registry soberano para as 10 imagens..."
for img in "${IMAGES[@]}"; do
    if ! grep -q "destination=gambi.2lp.in/lumen/$img:latest" "$WORKFLOW"; then
        echo "FALHA: Destino gambi.2lp.in/lumen/$img:latest ausente no workflow."
        FAILED=1
    else
        echo "OK: $img publicado em gambi.2lp.in/lumen/$img:latest"
    fi
done

# 6. Validar README.md: não deve referenciar docker.io/lumenpink
echo -n "-> Verificando conformidade do README.md com registry soberano... "
if grep -q "docker.io/lumenpink" "$README"; then
    echo "FALHA: README.md ainda orienta uso de docker.io/lumenpink."
    FAILED=1
else
    echo "OK: README.md atualizado com referências soberanas."
fi

# 7. Testes de Mutação (Fase 7 GOST)
echo "=== [MUTAÇÃO] Testando sensibilidade da auditoria contra mutantes ==="

# Mutação 1: Rejeitar reintrodução de docker.io
echo -n "-> [MUTAÇÃO] Injetando destino docker.io em workflow simulado... "
TMP_WF=$(mktemp)
sed 's|destination=gambi\.2lp\.in/lumen/gost-ci-cross|destination=docker.io/lumenpink/gost-ci-cross|' "$WORKFLOW" > "$TMP_WF"

if grep -q "docker.io" "$TMP_WF"; then
    echo "OK: Mutante de destino docker.io isolado e detectado com precisão."
else
    echo "FALHA: Mutação 1 não isolou docker.io."
    FAILED=1
fi
rm -f "$TMP_WF"

# Mutação 2: Rejeitar omissão de fail-fast de token
echo -n "-> [MUTAÇÃO] Omitindo fail-fast de token em workflow simulado... "
TMP_WF2=$(mktemp)
sed 's/FAIL-FAST/MUTATED-PASS/' "$WORKFLOW" > "$TMP_WF2"

if ! grep -q "FAIL-FAST" "$TMP_WF2"; then
    echo "OK: Mutante de remoção de fail-fast detectado com precisão."
else
    echo "FALHA: Mutação 2 falhou ao simular remoção de fail-fast."
    FAILED=1
fi
rm -f "$TMP_WF2"

# Mutação 3: Rejeitar checkout com URL absoluta
echo -n "-> [MUTAÇÃO] Injetando https://github.com/actions/checkout no workflow... "
TMP_WF3=$(mktemp)
sed 's|uses: actions/checkout@v4|uses: https://github.com/actions/checkout@v4|' "$WORKFLOW" > "$TMP_WF3"

if grep -q "https://github.com/actions/checkout" "$TMP_WF3"; then
    echo "OK: Mutante de sintaxe de checkout inválida detectado com precisão."
else
    echo "FALHA: Mutação 3 não detectou URL absoluta."
    FAILED=1
fi
rm -f "$TMP_WF3"

echo "================================================================="
if [[ "$FAILED" -eq 0 ]]; then
    echo "SUCESSO: Esteira de imagens 100% soberana em gambi.2lp.in!"
    exit 0
else
    echo "STATUS: RED (Falha em asserção ou teste de mutação)"
    exit 1
fi
