FROM node:24-bookworm-slim

ENV DEBIAN_FRONTEND=noninteractive
ENV RUST_VERSION=1.98.1
ENV RUSTUP_HOME=/root/.rustup
ENV CARGO_HOME=/root/.cargo
ENV PATH="/root/.cargo/bin:${PATH}"

# Cargo Cross Linkers
ENV CARGO_TARGET_I686_UNKNOWN_LINUX_GNU_LINKER=i686-linux-gnu-gcc
ENV CARGO_TARGET_ARMV7_UNKNOWN_LINUX_GNUEABIHF_LINKER=arm-linux-gnueabihf-gcc
ENV CARGO_TARGET_AARCH64_UNKNOWN_LINUX_GNU_LINKER=aarch64-linux-gnu-gcc
ENV CARGO_TARGET_AARCH64_UNKNOWN_LINUX_MUSL_LINKER=aarch64-linux-gnu-gcc
ENV CARGO_TARGET_X86_64_UNKNOWN_LINUX_MUSL_LINKER=musl-gcc
ENV CARGO_TARGET_X86_64_PC_WINDOWS_GNU_LINKER=x86_64-w64-mingw32-gcc

RUN apt-get update && apt-get install -y --no-install-recommends \
    curl \
    ca-certificates \
    git \
    build-essential \
    pkg-config \
    libssl-dev \
    tar \
    gzip \
    zip \
    unzip \
    musl-tools \
    python3 \
    python3-pip \
    gcc-i686-linux-gnu \
    libc6-dev-i386-cross \
    gcc-arm-linux-gnueabihf \
    libc6-dev-armhf-cross \
    gcc-aarch64-linux-gnu \
    libc6-dev-arm64-cross \
    gcc-mingw-w64-x86-64 \
    mingw-w64-tools \
    && rm -rf /var/lib/apt/lists/*

RUN pip3 install --no-cache-dir --break-system-packages cargo-zigbuild ziglang || \
    pip3 install --no-cache-dir cargo-zigbuild ziglang || true

RUN curl --proto '=https' --tlsv1.2 -fsSL https://sh.rustup.rs | sh -s -- \
    -y \
    --default-toolchain ${RUST_VERSION} \
    --profile minimal \
    && rustup target add x86_64-unknown-linux-gnu \
    && rustup target add x86_64-unknown-linux-musl \
    && rustup target add aarch64-unknown-linux-gnu \
    && rustup target add aarch64-unknown-linux-musl \
    && rustup target add x86_64-pc-windows-gnu \
    && rustup target add i686-unknown-linux-gnu \
    && rustup target add armv7-unknown-linux-gnueabihf \
    && rustc --version \
    && cargo --version

CMD ["bash"]
