FROM gambi.2lp.in/lumen/mirror-debian:bookworm-slim

ENV DEBIAN_FRONTEND=noninteractive
ENV ANDROID_HOME=/opt/android-sdk
ENV ANDROID_SDK_ROOT=/opt/android-sdk
ENV FLUTTER_HOME=/opt/flutter
ENV PATH=$FLUTTER_HOME/bin:$ANDROID_HOME/cmdline-tools/latest/bin:$ANDROID_HOME/platform-tools:$ANDROID_HOME/build-tools/34.0.0:$PATH

# 1. Dependências do sistema operacional
RUN echo 'Acquire::Retries "5";' > /etc/apt/apt.conf.d/80-retries \
    && apt-get update && apt-get install -y --no-install-recommends \
    bash \
    curl \
    git \
    unzip \
    zip \
    xz-utils \
    ca-certificates \
    openjdk-17-jdk-headless \
    libglu1-mesa \
    file \
    jq \
    && rm -rf /var/lib/apt/lists/*

# 2. Instalação do Android SDK Command-Line Tools & Plataforma Android 34
RUN mkdir -p ${ANDROID_HOME}/cmdline-tools && \
    curl -fsSL --retry 5 --retry-connrefused https://dl.google.com/android/repository/commandlinetools-linux-11076708_latest.zip -o /tmp/cmdline-tools.zip && \
    unzip -q /tmp/cmdline-tools.zip -d /tmp/cmdline-tools && \
    mv /tmp/cmdline-tools/cmdline-tools ${ANDROID_HOME}/cmdline-tools/latest && \
    rm -rf /tmp/cmdline-tools.zip /tmp/cmdline-tools && \
    yes | ${ANDROID_HOME}/cmdline-tools/latest/bin/sdkmanager --licenses >/dev/null 2>&1 && \
    ${ANDROID_HOME}/cmdline-tools/latest/bin/sdkmanager --install \
        "platform-tools" \
        "platforms;android-34" \
        "build-tools;34.0.0"

# 3. Instalação do Flutter SDK estável e pré-aquecimento offline
RUN git clone --depth 1 -b stable https://github.com/flutter/flutter.git ${FLUTTER_HOME} && \
    git config --global --add safe.directory ${FLUTTER_HOME} && \
    flutter config --no-analytics && \
    flutter precache --android && \
    yes | flutter doctor --android-licenses >/dev/null 2>&1 || true

CMD ["bash"]
