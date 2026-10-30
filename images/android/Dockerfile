FROM gambi.2lp.in/lumen/mirror-node:24-trixie-slim

ENV DEBIAN_FRONTEND=noninteractive
ENV RUST_VERSION=1.99.1
ENV RUSTUP_HOME=/root/.rustup
ENV CARGO_HOME=/root/.cargo

ENV JAVA_HOME=/usr/lib/jvm/java-21-openjdk-amd64
ENV ANDROID_HOME=/opt/android-sdk
ENV ANDROID_SDK_ROOT=/opt/android-sdk
ENV ANDROID_NDK_VERSION=r27c
ENV ANDROID_NDK_HOME=/opt/android-ndk/android-ndk-r27c
ENV NDK_HOME=/opt/android-ndk/android-ndk-r27c

ENV SCCACHE_VERSION=v0.18.0
ENV RUSTC_WRAPPER=/usr/local/bin/sccache
ENV SCCACHE_DIR=/root/.cache/sccache
ENV SCCACHE_CACHE_SIZE=50G

ENV DIOXUS_VERSION=v0.7.10

ENV PATH=$JAVA_HOME/bin:$ANDROID_HOME/cmdline-tools/latest/bin:$ANDROID_HOME/platform-tools:$ANDROID_HOME/build-tools/34.0.0:$ANDROID_NDK_HOME/toolchains/llvm/prebuilt/linux-x86_64/bin:/root/.cargo/bin:$PATH

# 1. Dependências do sistema operacional e Java 21 headless
RUN echo 'Acquire::Retries "5";' > /etc/apt/apt.conf.d/80-retries \
    && apt-get update && apt-get install -y --no-install-recommends \
    bash \
    curl \
    git \
    unzip \
    zip \
    tar \
    gzip \
    build-essential \
    pkg-config \
    libssl-dev \
    ca-certificates \
    openjdk-21-jdk-headless \
    python3 \
    python3-pil \
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

# 3. Instalação do Android NDK r27c
RUN mkdir -p /opt/android-ndk && \
    curl -fsSL --retry 5 --retry-connrefused https://dl.google.com/android/repository/android-ndk-${ANDROID_NDK_VERSION}-linux.zip -o /tmp/android-ndk.zip && \
    unzip -q /tmp/android-ndk.zip -d /opt/android-ndk && \
    rm -f /tmp/android-ndk.zip && \
    test -d ${ANDROID_NDK_HOME}

# 4. Instalação do Rust Toolchain e targets Android
RUN curl --proto '=https' --tlsv1.2 -fsSL https://sh.rustup.rs | sh -s -- \
    -y \
    --default-toolchain ${RUST_VERSION} \
    --profile minimal \
    && rustup component add rustfmt clippy \
    && rustup target add aarch64-linux-android \
    && rustup target add x86_64-linux-android \
    && rustup target add x86_64-unknown-linux-gnu \
    && rustup target add x86_64-unknown-linux-musl \
    && rustc --version \
    && cargo --version

# 5. Instalação do sccache
RUN curl -fsSL "https://github.com/mozilla/sccache/releases/download/${SCCACHE_VERSION}/sccache-${SCCACHE_VERSION}-x86_64-unknown-linux-musl.tar.gz" \
    | tar -xz -C /usr/local/bin --strip-components=1 "sccache-${SCCACHE_VERSION}-x86_64-unknown-linux-musl/sccache" \
    && chmod +x /usr/local/bin/sccache \
    && sccache --version

# 6. Instalação do Dioxus CLI (dx)
RUN curl -fsSL "https://gambi.2lp.in/api/packages/lumen/generic/dioxus/${DIOXUS_VERSION}/dx-x86_64-unknown-linux-gnu.tar.gz" \
    | tar -xz -C /usr/local/bin \
    && chmod +x /usr/local/bin/dx \
    && dx --version

CMD ["bash"]
