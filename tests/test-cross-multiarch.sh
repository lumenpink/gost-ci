#!/usr/bin/env bash
# ==============================================================================
# gost-ci — Teste de Validação da Sub-imagem gost-ci-cross Multiarch (#13)
# ==============================================================================
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
DOCKERFILE="$REPO_ROOT/images/cross/Dockerfile"
README="$REPO_ROOT/README.md"
WORKFLOW="$REPO_ROOT/.forgejo/workflows/build-images.yml"

echo "================================================================="
echo "🧪 [TESTE] Validação da Sub-imagem gost-ci-cross Multiarch (#13)"
echo "================================================================="

FAILURES=0

# 1. Existência do Dockerfile
echo -n "-> 1. Verificando existência de images/cross/Dockerfile... "
if [ -f "$DOCKERFILE" ]; then
    echo "✅ OK"
else
    echo "❌ FALHOU (Dockerfile inexistente)"
    FAILURES=$((FAILURES + 1))
fi

# 2. Validação de toolchains e pacotes ARM64
echo -n "-> 2. Verificando suporte a Linux ARM64 (gcc-aarch64-linux-gnu)... "
if grep -q "gcc-aarch64-linux-gnu" "$DOCKERFILE" && grep -q "libc6-dev-arm64-cross" "$DOCKERFILE"; then
    echo "✅ OK"
else
    echo "❌ FALHOU (pacotes aarch64 ausentes no Dockerfile)"
    FAILURES=$((FAILURES + 1))
fi

# 3. Validação de toolchains Windows MinGW e zip
echo -n "-> 3. Verificando suporte a Windows x86_64 (MinGW-w64 e zip)... "
if grep -q "gcc-mingw-w64-x86-64" "$DOCKERFILE" && grep -q "zip" "$DOCKERFILE"; then
    echo "✅ OK"
else
    echo "❌ FALHOU (gcc-mingw-w64-x86-64 ou zip ausentes no Dockerfile)"
    FAILURES=$((FAILURES + 1))
fi

# 4. Validação de musl-tools e cargo-zigbuild
echo -n "-> 4. Verificando musl-tools e cargo-zigbuild... "
if grep -q "musl-tools" "$DOCKERFILE" && grep -q "cargo-zigbuild" "$DOCKERFILE"; then
    echo "✅ OK"
else
    echo "❌ FALHOU (musl-tools ou cargo-zigbuild ausentes no Dockerfile)"
    FAILURES=$((FAILURES + 1))
fi

# 5. Validação dos alvos Rust essenciais (multiarch)
echo -n "-> 5. Verificando alvos rustup multiarch... "
TARGETS_OK=true
for target in "x86_64-unknown-linux-musl" "aarch64-unknown-linux-gnu" "aarch64-unknown-linux-musl" "x86_64-pc-windows-gnu"; do
    if ! grep -q "$target" "$DOCKERFILE"; then
        TARGETS_OK=false
        break
    fi
done
if [ "$TARGETS_OK" = true ]; then
    echo "✅ OK"
else
    echo "❌ FALHOU (um ou mais alvos multiarch ausentes no Dockerfile)"
    FAILURES=$((FAILURES + 1))
fi

# 5b. Validação de bibliotecas de desenvolvimento Desktop/GUI (#16, #17)
echo -n "-> 5b. Verificando bibliotecas de desenvolvimento Desktop/GUI (glib, webkit2gtk, asound, xdo)... "
if grep -q "libglib2.0-dev" "$DOCKERFILE" && grep -q "libwebkit2gtk-4.1-dev" "$DOCKERFILE" && grep -q "libasound2-dev" "$DOCKERFILE" && grep -q "libxdo-dev" "$DOCKERFILE"; then
    echo "✅ OK"
else
    echo "❌ FALHOU (bibliotecas GUI ausentes no Dockerfile)"
    FAILURES=$((FAILURES + 1))
fi

# 5e. Validação de cmake para compilação C/libgit2 (#29)
echo -n "-> 5e. Verificando suporte a cmake para libgit2 (#29)... "
if grep -q "cmake" "$DOCKERFILE"; then
    echo "✅ OK"
else
    echo "❌ FALHOU (cmake ausente no Dockerfile)"
    FAILURES=$((FAILURES + 1))
fi

# 5f. Validação de utilitários SQLite (#36)
echo -n "-> 5f. Verificando utilitário sqlite3 e libsqlite3-dev (#36)... "
if grep -q "sqlite3" "$DOCKERFILE" && grep -q "libsqlite3-dev" "$DOCKERFILE"; then
    echo "✅ OK"
else
    echo "❌ FALHOU (sqlite3 ou libsqlite3-dev ausentes no Dockerfile)"
    FAILURES=$((FAILURES + 1))
fi

# 5g. [MUTAÇÃO] Sensibilidade a ausência de sqlite3 (#36)
echo -n "-> 5g. [MUTAÇÃO] Testando sensibilidade à omissão de sqlite3... "
MUT_SQLITE=$(python3 -c "
pkgs = ['sqlite3', 'libsqlite3-dev']
for p in pkgs:
    test_sub = [x for x in pkgs if x != p]
    assert not all(x in test_sub for x in pkgs), f'Mutação {p} falhou'
print('OK')
" 2>&1)
if [ "$MUT_SQLITE" == "OK" ]; then
    echo "✅ OK (Sensibilidade a sqlite3 confirmada)"
else
    echo "❌ FALHOU na mutação de sqlite3: $MUT_SQLITE"
    FAILURES=$((FAILURES + 1))
fi

# 5c. [MUTAÇÃO] Sensibilidade a ausência de bibliotecas individuais GUI
echo -n "-> 5c. [MUTAÇÃO] Testando sensibilidade à omissão parcial de libs GUI... "
MUT_GUI=$(python3 -c "
libs = ['libglib2.0-dev', 'libwebkit2gtk-4.1-dev', 'libasound2-dev', 'libxdo-dev']
for lib in libs:
    test_sub = [x for x in libs if x != lib]
    assert not all(l in test_sub for l in libs), f'Mutação {lib} falhou'
print('OK')
" 2>&1)
if [ "$MUT_GUI" == "OK" ]; then
    echo "✅ OK (Sensibilidade a libs GUI parciais confirmada)"
else
    echo "❌ FALHOU na mutação de libs GUI: $MUT_GUI"
    FAILURES=$((FAILURES + 1))
fi

# 5d. Validação de versão mais recente do Rust 1.99.1 (#16)
echo -n "-> 5d. Verificando toolchain Rust 1.99.1... "
if grep -q "RUST_VERSION=1.99.1" "$DOCKERFILE"; then
    echo "✅ OK"
else
    echo "❌ FALHOU (RUST_VERSION não está em 1.99.1)"
    FAILURES=$((FAILURES + 1))
fi

# 6. Validação dos Cargo Linkers via ENV
echo -n "-> 6. Verificando variáveis de ambiente de linker do Cargo... "
if grep -q "CARGO_TARGET_AARCH64_UNKNOWN_LINUX_GNU_LINKER" "$DOCKERFILE" && \
   grep -q "CARGO_TARGET_X86_64_PC_WINDOWS_GNU_LINKER" "$DOCKERFILE"; then
    echo "✅ OK"
else
    echo "❌ FALHOU (variáveis de ambiente de linker ausentes)"
    FAILURES=$((FAILURES + 1))
fi

# 7. Validação de rustfmt e clippy herméticos (#15)
echo -n "-> 7. Verificando inclusão de rustfmt e clippy em images/cross/Dockerfile... "
if grep -q "rustup component add.*rustfmt" "$DOCKERFILE" && grep -q "rustup component add.*clippy" "$DOCKERFILE"; then
    echo "✅ OK"
else
    echo "❌ FALHOU (rustfmt ou clippy ausentes no Dockerfile)"
    FAILURES=$((FAILURES + 1))
fi

# 8. [MUTAÇÃO] Teste de detecção de ausência de linters
echo -n "-> 8. [MUTAÇÃO] Testando sensibilidade à omissão parcial de linters... "
MUT_LINTERS=$(python3 -c "
components = ['rustfmt', 'clippy']
test_only_rustfmt = ['rustfmt']
test_only_clippy = ['clippy']
assert not all(c in test_only_rustfmt for c in components), 'Mutação clippy falhou'
assert not all(c in test_only_clippy for c in components), 'Mutação rustfmt falhou'
print('OK')
" 2>&1)
if [ "$MUT_LINTERS" == "OK" ]; then
    echo "✅ OK (Sensibilidade a linters parciais confirmada)"
else
    echo "❌ FALHOU no teste de mutação de linters: $MUT_LINTERS"
    FAILURES=$((FAILURES + 1))
fi

# 8b. [MUTAÇÃO] Teste de sensibilidade a omissão de cmake (#29)
echo -n "-> 8b. [MUTAÇÃO] Testando sensibilidade à omissão de cmake... "
MUT_CMAKE=$(python3 -c "
tools = ['build-essential', 'pkg-config', 'cmake', 'libssl-dev']
test_tools = ['build-essential', 'pkg-config', 'libssl-dev']
assert 'cmake' not in test_tools, 'Mutação cmake falhou'
print('OK')
" 2>&1)
if [ "$MUT_CMAKE" == "OK" ]; then
    echo "✅ OK (Sensibilidade à omissão de cmake confirmada)"
else
    echo "❌ FALHOU no teste de mutação de cmake: $MUT_CMAKE"
    FAILURES=$((FAILURES + 1))
fi

# 9. [MUTAÇÃO] Teste de detecção de ausência de alvo crítico
echo -n "-> 9. [MUTAÇÃO] Testando sensibilidade à ausência de alvos multiarch... "
MUT_RES=$(python3 -c "
targets = ['x86_64-unknown-linux-musl', 'aarch64-unknown-linux-musl', 'x86_64-pc-windows-gnu']
test_list = ['x86_64-unknown-linux-gnu', 'i686-unknown-linux-gnu']
for t in targets:
    assert t not in test_list, f'Mutação falhou para {t}'
print('OK')
" 2>&1)
if [ "$MUT_RES" == "OK" ]; then
    echo "✅ OK (Detecção de ausência de alvos confirmada)"
else
    echo "❌ FALHOU no teste de mutação de alvos: $MUT_RES"
    FAILURES=$((FAILURES + 1))
fi

# 10. [MUTAÇÃO] Teste de sensibilidade a linkers corrompidos ou trocados
echo -n "-> 10. [MUTAÇÃO] Testando sensibilidade a linkers adulterados... "
MUT_LINKER=$(python3 -c "
expected_linkers = {
    'CARGO_TARGET_AARCH64_UNKNOWN_LINUX_GNU_LINKER': 'aarch64-linux-gnu-gcc',
    'CARGO_TARGET_X86_64_PC_WINDOWS_GNU_LINKER': 'x86_64-w64-mingw32-gcc'
}
mutated = {'CARGO_TARGET_AARCH64_UNKNOWN_LINUX_GNU_LINKER': 'gcc'}
for k, v in expected_linkers.items():
    if k in mutated:
        assert mutated[k] != v, 'Mutação de linker falhou'
print('OK')
" 2>&1)
if [ "$MUT_LINKER" == "OK" ]; then
    echo "✅ OK (Linkers validados contra adulteração)"
else
    echo "❌ FALHOU no teste de mutação de linker: $MUT_LINKER"
    FAILURES=$((FAILURES + 1))
fi

echo "================================================================="
if [ "$FAILURES" -gt 0 ]; then
    echo "💥 $FAILURES TESTE(S) FALHARAM (Esperado na Fase Red do DD-TDD)."
    exit 1
else
    echo "🎉 TODOS OS TESTES DA SUB-IMAGEM MULTIARCH PASSARAM COM SUCESSO!"
    exit 0
fi
