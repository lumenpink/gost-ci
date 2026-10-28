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
    openssh-client \
    build-essential \
    pkg-config \
    libssl-dev \
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

RUN CCCP_TARBALL_URL=$(curl -fsSL https://banca.2lp.in/downloads/cccp/index.json 2>/dev/null | grep -o 'https://bucket.2lp.in/downloads/cccp/nightly/cccp-[^"]*-linux-amd64.tar.gz' | head -n 1) \
    && if [ -n "$CCCP_TARBALL_URL" ]; then \
         curl -fsSL "$CCCP_TARBALL_URL" | tar -xz -C /usr/local/bin cccp; \
       else \
         curl -fsSL "https://bucket.2lp.in/downloads/cccp/nightly/cccp.sh" -o /usr/local/bin/cccp; \
       fi \
    && chmod +x /usr/local/bin/cccp \
    && (cccp --version || cccp version)

ENV RUSTC_WRAPPER=/usr/local/bin/sccache
ENV SCCACHE_DIR=/root/.cache/sccache
ENV SCCACHE_CACHE_SIZE=50G

CMD ["bash"]
