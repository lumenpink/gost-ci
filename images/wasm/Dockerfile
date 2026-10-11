FROM node:24-trixie-slim

ENV DEBIAN_FRONTEND=noninteractive
ENV RUST_VERSION=1.98.1
ENV WASM_PACK_VERSION=v0.13.1
ENV RUSTUP_HOME=/root/.rustup
ENV CARGO_HOME=/root/.cargo
ENV PATH="/root/.cargo/bin:${PATH}"

RUN apt-get update && apt-get install -y --no-install-recommends \
    curl \
    ca-certificates \
    git \
    build-essential \
    pkg-config \
    libssl-dev \
    tar \
    gzip \
    && rm -rf /var/lib/apt/lists/*

RUN curl --proto '=https' --tlsv1.2 -fsSL https://sh.rustup.rs | sh -s -- \
    -y \
    --default-toolchain ${RUST_VERSION} \
    --profile minimal \
    && rustup component add rustfmt clippy \
    && rustup target add wasm32-unknown-unknown \
    && rustc --version \
    && cargo --version

RUN curl -fsSL "https://github.com/rustwasm/wasm-pack/releases/download/${WASM_PACK_VERSION}/wasm-pack-${WASM_PACK_VERSION}-x86_64-unknown-linux-musl.tar.gz" \
    | tar -xz -C /usr/local/bin --strip-components=1 "wasm-pack-${WASM_PACK_VERSION}-x86_64-unknown-linux-musl/wasm-pack" \
    && chmod +x /usr/local/bin/wasm-pack \
    && wasm-pack --version

ENV DIOXUS_VERSION=v0.7.10

RUN curl -fsSL "https://github.com/DioxusLabs/dioxus/releases/download/${DIOXUS_VERSION}/dx-x86_64-unknown-linux-gnu.tar.gz" \
    | tar -xz -C /usr/local/bin \
    && chmod +x /usr/local/bin/dx \
    && dx --version

RUN npm install -g wrangler \
    && wrangler --version

CMD ["bash"]

