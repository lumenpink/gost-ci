# Especificação Técnica: Sub-imagem Atômica `gost-ci-flutter`

## 1. Contexto e Motivação
A conformidade com a norma GOST exige que ambientes de compilação de CI/CD sejam atômicos, herméticos e determinísticos. O cliente móvel do Mocambo e futuros clientes móveis do ecossistema dependem do Flutter SDK e da toolchain Android.
Para evitar que runners de CI dependam de downloads em tempo de execução ou gerem artefatos "stub" esqueléticos por ausência de toolchain nativa, criamos a imagem atômica `codeberg.org/lumenpink/gost-ci-flutter:latest`.

## 2. Requisitos Técnicos
1. **Base do Sistema Operacional**:
   - `ubuntu:24.04` ou `debian:bookworm-slim` com utilitários essenciais (`bash`, `curl`, `git`, `unzip`, `xz-utils`, `zip`, `ca-certificates`).
2. **Java Development Kit**:
   - `openjdk-17-jdk-headless` (compatível com Android Gradle Plugin 8.x e Gradle 8.x/9.x).
3. **Android SDK Command-Line Tools**:
   - `cmdline-tools` oficial com aceitação automática de licenças (`sdkmanager --licenses`).
   - Plataforma Android: `platforms;android-34`.
   - Build Tools: `build-tools;34.0.0` (incluindo `aapt`, `aapt2`, `apksigner`, `zipalign`).
4. **Flutter SDK**:
   - Canal `stable` mais recente (3.27.x ou 3.24.x).
   - `flutter config --no-analytics` para telemetria zero.
   - `flutter precache --android` pré-aquecido na imagem para conter os binários do motor Android (`arm64-v8a`, `armeabi-v7a`, `x86_64`).
5. **Variáveis de Ambiente**:
   - `ANDROID_HOME=/opt/android-sdk`
   - `ANDROID_SDK_ROOT=/opt/android-sdk`
   - `FLUTTER_HOME=/opt/flutter`
   - `PATH=$FLUTTER_HOME/bin:$ANDROID_HOME/cmdline-tools/latest/bin:$ANDROID_HOME/platform-tools:$ANDROID_HOME/build-tools/34.0.0:$PATH`
6. **Conformidade CI**:
   - Pipeline de construção e publicação automática no Codeberg Registry via Kaniko em `.forgejo/workflows/ci.yml`.
