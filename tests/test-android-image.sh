#!/usr/bin/env bash
# ==============================================================================
# Teste de Conformidade — Sub-Imagem gost-ci-android (#24)
# ==============================================================================
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DOCKERFILE="$REPO_ROOT/images/android/Dockerfile"
CROSS_DOCKERFILE="$REPO_ROOT/images/cross/Dockerfile"
WORKFLOW="$REPO_ROOT/.forgejo/workflows/build-images.yml"
TAGS_TEST="$REPO_ROOT/tests/test-docker-canonical-tags.sh"

echo "🧪 [TESTE] Verificando especificações da sub-imagem gost-ci-android..."

# 1. Existência do Dockerfile
if [ ! -f "$DOCKERFILE" ]; then
    echo "❌ FALHA: Dockerfile não encontrado em $DOCKERFILE"
    exit 1
fi
echo "✓ Dockerfile presente em images/android/Dockerfile"

# 2. Variáveis de ambiente canônicas do Android SDK e NDK
grep -q "ENV ANDROID_HOME=/opt/android-sdk" "$DOCKERFILE" || { echo "❌ FALHA: ANDROID_HOME não definido em $DOCKERFILE"; exit 1; }
grep -q "ENV ANDROID_NDK_HOME=" "$DOCKERFILE" || { echo "❌ FALHA: ANDROID_NDK_HOME não definido em $DOCKERFILE"; exit 1; }
grep -q "ENV JAVA_HOME=" "$DOCKERFILE" || { echo "❌ FALHA: JAVA_HOME não definido em $DOCKERFILE"; exit 1; }
grep -q "ENV RUSTC_WRAPPER=" "$DOCKERFILE" || { echo "❌ FALHA: RUSTC_WRAPPER não definido em $DOCKERFILE"; exit 1; }
echo "✓ Variáveis de ambiente canônicas presentes em images/android/Dockerfile"

# 3. Pacotes Android SDK essenciais
grep -q "cmdline-tools" "$DOCKERFILE" || { echo "❌ FALHA: cmdline-tools ausente em $DOCKERFILE"; exit 1; }
grep -q "platforms;android-34" "$DOCKERFILE" || { echo "❌ FALHA: platform android-34 ausente em $DOCKERFILE"; exit 1; }
grep -q "build-tools;34.0.0" "$DOCKERFILE" || { echo "❌ FALHA: build-tools 34.0.0 ausente em $DOCKERFILE"; exit 1; }
echo "✓ Android SDK configurado para Android 34 e build-tools 34.0.0"

# 4. Provisão do Android NDK
grep -q "android-ndk" "$DOCKERFILE" || { echo "❌ FALHA: Android NDK ausente em $DOCKERFILE"; exit 1; }
echo "✓ Android NDK declarado em images/android/Dockerfile"

# 5. Targets Rust para Android (em images/android/Dockerfile e images/cross/Dockerfile)
grep -q "aarch64-linux-android" "$DOCKERFILE" || { echo "❌ FALHA: target aarch64-linux-android ausente em $DOCKERFILE"; exit 1; }
grep -q "x86_64-linux-android" "$DOCKERFILE" || { echo "❌ FALHA: target x86_64-linux-android ausente em $DOCKERFILE"; exit 1; }
grep -q "aarch64-linux-android" "$CROSS_DOCKERFILE" || { echo "❌ FALHA: target aarch64-linux-android ausente em $CROSS_DOCKERFILE"; exit 1; }
grep -q "x86_64-linux-android" "$CROSS_DOCKERFILE" || { echo "❌ FALHA: target x86_64-linux-android ausente em $CROSS_DOCKERFILE"; exit 1; }
echo "✓ Targets Rust para Android presentes nas imagens"

# 6. Provisão de Dioxus CLI (dx)
grep -q "dx" "$DOCKERFILE" || { echo "❌ FALHA: Dioxus dx ausente em $DOCKERFILE"; exit 1; }
echo "✓ Dioxus CLI declarado em images/android/Dockerfile"

# 7. Declaração no Workflow Kaniko
grep -q "gost-ci-android" "$WORKFLOW" || { echo "❌ FALHA: gost-ci-android ausente em $WORKFLOW"; exit 1; }
grep -q "ndk27-sdk34" "$WORKFLOW" || { echo "❌ FALHA: tag ndk27-sdk34 ausente em $WORKFLOW"; exit 1; }
echo "✓ Imagem gost-ci-android declarada no workflow build-images.yml"

# 8. Declaração no script de tags canônicas
grep -q "gost-ci-android" "$TAGS_TEST" || { echo "❌ FALHA: gost-ci-android ausente em $TAGS_TEST"; exit 1; }
echo "✓ Tags canônicas registradas em test-docker-canonical-tags.sh"

echo "🎉 [SUCESSO] Todos os critérios de conformidade da sub-imagem gost-ci-android foram atendidos!"
