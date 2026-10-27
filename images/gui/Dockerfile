FROM gambi.2lp.in/lumen/mirror-node:24-bookworm-slim

ENV DEBIAN_FRONTEND=noninteractive
ENV RUST_VERSION=1.99.1
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
    libglib2.0-dev \
    libwebkit2gtk-4.1-dev \
    libasound2-dev \
    libxdo-dev \
    && rm -rf /var/lib/apt/lists/*

RUN curl --proto '=https' --tlsv1.2 -fsSL https://sh.rustup.rs | sh -s -- \
    -y \
    --default-toolchain ${RUST_VERSION} \
    --profile minimal \
    && rustup component add rustfmt clippy \
    && rustc --version \
    && cargo --version

ENV SCCACHE_VERSION=v0.18.0

RUN curl -fsSL "https://github.com/mozilla/sccache/releases/download/${SCCACHE_VERSION}/sccache-${SCCACHE_VERSION}-x86_64-unknown-linux-musl.tar.gz" \
    | tar -xz -C /usr/local/bin --strip-components=1 "sccache-${SCCACHE_VERSION}-x86_64-unknown-linux-musl/sccache" \
    && chmod +x /usr/local/bin/sccache \
    && sccache --version

CMD ["bash"]
