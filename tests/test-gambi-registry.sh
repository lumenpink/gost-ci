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

echo "================================================================="
if [[ "$FAILED" -eq 0 ]]; then
    echo "SUCESSO: Esteira de imagens 100% soberana em gambi.2lp.in!"
    exit 0
else
    echo "STATUS: RED (Requisitos pendentes de implementação)"
    exit 1
fi
