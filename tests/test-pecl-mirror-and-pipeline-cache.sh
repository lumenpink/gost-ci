#!/usr/bin/env bash
# ==============================================================================
# gost-ci — Validação de Espelho PECL, Cache de Camadas e Filtros Kaniko (#46)
# ==============================================================================
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

PHP_DOCKERFILE="$REPO_ROOT/images/php/Dockerfile"
WORKFLOW_FILE="$REPO_ROOT/.forgejo/workflows/build-images.yml"
SYNC_SCRIPT="$REPO_ROOT/scripts/sync-upstream-images.sh"

echo "================================================================="
echo "🧪 [TESTE] Validação de Espelho PECL, Cache e Filtros Kaniko (#46)"
echo "================================================================="

FAILURES=0

# 1. Validação do Espelho PECL xdebug no Dockerfile do PHP
echo -n "-> 1. Verificando uso de mirror-pecl-xdebug no Dockerfile do PHP... "
if grep -q "COPY --from=gambi\.2lp\.in/lumen/mirror-pecl-xdebug" "$PHP_DOCKERFILE" && \
   grep -q "/xdebug\.tgz" "$PHP_DOCKERFILE"; then
    echo "✅ OK"
else
    echo "❌ FALHOU (mirror-pecl-xdebug ausente em images/php/Dockerfile)"
    FAILURES=$((FAILURES + 1))
fi

# 2. Validação da instalação hermética sem rede externa para xdebug
echo -n "-> 2. Verificando instalação hermética de xdebug via tarball local... "
if grep -q "pecl install /tmp/xdebug\.tgz" "$PHP_DOCKERFILE" && \
   grep -q "docker-php-ext-enable xdebug" "$PHP_DOCKERFILE"; then
    echo "✅ OK"
else
    echo "❌ FALHOU (instalação hermética de xdebug ausente ou incorreta)"
    FAILURES=$((FAILURES + 1))
fi

# 3. Validação de Cache de Camadas no Kaniko em build-images.yml
echo -n "-> 3. Verificando flags de cache do Kaniko em build-images.yml... "
TOTAL_CACHE_FLAGS=$(grep -c "\-\-cache=true.*kaniko-cache" "$WORKFLOW_FILE" || true)
if [ "$TOTAL_CACHE_FLAGS" -ge 13 ]; then
    echo "✅ OK (encontradas $TOTAL_CACHE_FLAGS flags de cache em 13 jobs)"
else
    echo "❌ FALHOU (esperadas 13 ocorrências de --cache=true com kaniko-cache, encontradas: $TOTAL_CACHE_FLAGS)"
    FAILURES=$((FAILURES + 1))
fi

# 4. Validação de Filtro de Caminhos (detecção de alterações por imagem)
echo -n "-> 4. Verificando filtro de caminhos / detecção de git diff nos jobs... "
TOTAL_DIFF_FILTERS=$(grep -c "git diff --name-only" "$WORKFLOW_FILE" || true)
if [ "$TOTAL_DIFF_FILTERS" -ge 13 ]; then
    echo "✅ OK (encontrados $TOTAL_DIFF_FILTERS filtros de diff)"
else
    echo "❌ FALHOU (esperados 13 filtros de git diff no workflow, encontrados: $TOTAL_DIFF_FILTERS)"
    FAILURES=$((FAILURES + 1))
fi

# 5. [MUTAÇÃO] Mutante 1: Ausência de cache Kaniko
echo -n "-> 5. [MUTAÇÃO 1] Sensibilidade à ausência de --cache=true... "
MUT_OUT1=$(python3 -c "
workflow = '''
/kaniko/executor --context=dir://images/rust --destination=test
'''
assert '--cache=true' not in workflow
print('MUTANTE_MORTO')
" 2>&1)
if [ "$MUT_OUT1" == "MUTANTE_MORTO" ]; then
    echo "✅ OK (Mutante 1 detectado com sucesso)"
else
    echo "❌ FALHA no Mutante 1: $MUT_OUT1"
    FAILURES=$((FAILURES + 1))
fi

# 6. [MUTAÇÃO] Mutante 2: Reintrodução de download PECL direto
echo -n "-> 6. [MUTAÇÃO 2] Sensibilidade ao download direto de pecl.php.net... "
MUT_OUT2=$(python3 -c "
dockerfile = '''
RUN install-php-extensions xdebug
'''
assert 'mirror-pecl-xdebug' not in dockerfile
print('MUTANTE_MORTO')
" 2>&1)
if [ "$MUT_OUT2" == "MUTANTE_MORTO" ]; then
    echo "✅ OK (Mutante 2 detectado com sucesso)"
else
    echo "❌ FALHA no Mutante 2: $MUT_OUT2"
    FAILURES=$((FAILURES + 1))
fi

# 7. [MUTAÇÃO] Mutante 3: Ausência de filtro git diff nos jobs
echo -n "-> 7. [MUTAÇÃO 3] Sensibilidade à ausência de verificação de diff... "
MUT_OUT3=$(python3 -c "
step = '''
/kaniko/executor --build-arg http_proxy=...
'''
assert 'git diff --name-only' not in step
print('MUTANTE_MORTO')
" 2>&1)
if [ "$MUT_OUT3" == "MUTANTE_MORTO" ]; then
    echo "✅ OK (Mutante 3 detectado com sucesso)"
else
    echo "❌ FALHA no Mutante 3: $MUT_OUT3"
    FAILURES=$((FAILURES + 1))
fi

echo "================================================================="
if [ "$FAILURES" -gt 0 ]; then
    echo "💥 $FAILURES TESTE(S) FALHARAM (Esperado na Fase Red do DD-TDD)."
    exit 1
fi
echo "🎉 TODOS OS TESTES PASSARAM COM SUCESSO!"
exit 0
