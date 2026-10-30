FROM gambi.2lp.in/lumen/mirror-node:24-trixie-slim

ENV DEBIAN_FRONTEND=noninteractive
ENV RUST_VERSION=1.99.1
ENV WASM_PACK_VERSION=v0.13.1
ENV RUSTUP_HOME=/root/.rustup
ENV CARGO_HOME=/root/.cargo
ENV PATH="/root/.cargo/bin:${PATH}"

RUN echo 'Acquire::Retries "5";' > /etc/apt/apt.conf.d/80-retries \
    && apt-get update && apt-get install -y --no-install-recommends \
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

ENV SCCACHE_VERSION=v0.18.0

RUN curl -fsSL "https://github.com/mozilla/sccache/releases/download/${SCCACHE_VERSION}/sccache-${SCCACHE_VERSION}-x86_64-unknown-linux-musl.tar.gz" \
    | tar -xz -C /usr/local/bin --strip-components=1 "sccache-${SCCACHE_VERSION}-x86_64-unknown-linux-musl/sccache" \
    && chmod +x /usr/local/bin/sccache \
    && sccache --version

RUN curl -fsSL "https://github.com/rustwasm/wasm-pack/releases/download/${WASM_PACK_VERSION}/wasm-pack-${WASM_PACK_VERSION}-x86_64-unknown-linux-musl.tar.gz" \
    | tar -xz -C /usr/local/bin --strip-components=1 "wasm-pack-${WASM_PACK_VERSION}-x86_64-unknown-linux-musl/wasm-pack" \
    && chmod +x /usr/local/bin/wasm-pack \
    && wasm-pack --version

ENV WASM_BINDGEN_VERSION=0.2.129

RUN curl -fsSL "https://github.com/wasm-bindgen/wasm-bindgen/releases/download/${WASM_BINDGEN_VERSION}/wasm-bindgen-${WASM_BINDGEN_VERSION}-x86_64-unknown-linux-musl.tar.gz" \
    | tar -xz -C /usr/local/bin --strip-components=1 "wasm-bindgen-${WASM_BINDGEN_VERSION}-x86_64-unknown-linux-musl/wasm-bindgen" \
    && chmod +x /usr/local/bin/wasm-bindgen \
    && ln -sf /usr/local/bin/wasm-bindgen /root/.cargo/bin/wasm-bindgen \
    && wasm-bindgen --version

ENV BINARYEN_VERSION=version_122

RUN curl -fsSL "https://github.com/WebAssembly/binaryen/releases/download/${BINARYEN_VERSION}/binaryen-${BINARYEN_VERSION}-x86_64-linux.tar.gz" \
    | tar -xz -C /usr/local/bin --strip-components=2 "binaryen-${BINARYEN_VERSION}/bin/wasm-opt" \
    && chmod +x /usr/local/bin/wasm-opt \
    && wasm-opt --version

ENV DIOXUS_VERSION=v0.7.10

RUN curl -fsSL "https://gambi.2lp.in/api/packages/lumen/generic/dioxus/${DIOXUS_VERSION}/dx-x86_64-unknown-linux-gnu.tar.gz" \
    | tar -xz -C /usr/local/bin \
    && chmod +x /usr/local/bin/dx \
    && dx --version

RUN npm install -g wrangler esbuild \
    && wrangler --version \
    && esbuild --version

ENV RUSTC_WRAPPER=/usr/local/bin/sccache
ENV SCCACHE_DIR=/root/.cache/sccache
ENV SCCACHE_CACHE_SIZE=50G

CMD ["bash"]
