FROM gambi.2lp.in/lumen/mirror-node:24-bookworm-slim

ENV DEBIAN_FRONTEND=noninteractive
ENV RUST_VERSION=1.99.1
ENV RUSTUP_HOME=/root/.rustup
ENV CARGO_HOME=/root/.cargo
ENV PATH="/root/.cargo/bin:${PATH}"

RUN echo 'Acquire::Retries "5";' > /etc/apt/apt.conf.d/80-retries \
    && echo 'Acquire::http::Timeout "60";' >> /etc/apt/apt.conf.d/80-retries \
    && echo 'Acquire::https::Timeout "60";' >> /etc/apt/apt.conf.d/80-retries \
    && echo 'Acquire::http::Retries "5";' >> /etc/apt/apt.conf.d/80-retries \
    && echo 'Acquire::https::Retries "5";' >> /etc/apt/apt.conf.d/80-retries \
    && ([ -n "$http_proxy" ] && echo "Acquire::http::Proxy \"$http_proxy\";" > /etc/apt/apt.conf.d/01proxy || true) \
    && (apt-get update || (sleep 3 && rm -f /etc/apt/apt.conf.d/01proxy && apt-get update)) \
    && apt-get install -y --no-install-recommends \
    curl \
    ca-certificates \
    git \
    openssh-client \
    build-essential \
    pkg-config \
    libssl-dev \
    && rm -f /etc/apt/apt.conf.d/01proxy \
    && rm -rf /var/lib/apt/lists/*

RUN curl --proto '=https' --tlsv1.2 -fsSL https://sh.rustup.rs | sh -s -- \
    -y \
    --default-toolchain ${RUST_VERSION} \
    --profile minimal \
    && rustup component add rustfmt clippy \
    && rustc --version \
    && cargo --version

ENV SCCACHE_VERSION=v0.18.0

RUN curl -fsSL --retry 5 --retry-connrefused --retry-delay 2 "https://github.com/mozilla/sccache/releases/download/${SCCACHE_VERSION}/sccache-${SCCACHE_VERSION}-x86_64-unknown-linux-musl.tar.gz" \
    | tar -xz -C /usr/local/bin --strip-components=1 "sccache-${SCCACHE_VERSION}-x86_64-unknown-linux-musl/sccache" \
    && chmod +x /usr/local/bin/sccache \
    && sccache --version

# Ferramentas Canônicas do Ecossistema de Dev (Governança, Regras e Catálogo)
RUN curl -fsSL "https://gambi.2lp.in/api/packages/lumen/generic/cccp/nightly/cccp-linux-amd64" -o /usr/local/bin/cccp \
    && chmod +x /usr/local/bin/cccp \
    && cccp --help >/dev/null \
    && curl -fsSL "https://gambi.2lp.in/api/packages/lumen/generic/lunokhod/nightly/lunokhod-linux-amd64" -o /usr/local/bin/lunokhod \
    && chmod +x /usr/local/bin/lunokhod \
    && lunokhod --version \
    && curl -fsSL "https://gambi.2lp.in/api/packages/lumen/generic/gossnab/nightly/gossnab-linux-amd64" -o /usr/local/bin/gossnab \
    && chmod +x /usr/local/bin/gossnab \
    && gossnab --version \
    && curl -fsSL "https://gambi.2lp.in/api/packages/lumen/generic/gossnab/nightly/gn-linux-amd64" -o /usr/local/bin/gn \
    && chmod +x /usr/local/bin/gn \
    && gn --version \
    && curl -fsSL "https://gambi.2lp.in/api/packages/lumen/generic/kontur/nightly/kontur-linux-amd64" -o /usr/local/bin/kontur \
    && chmod +x /usr/local/bin/kontur \
    && kontur --version \
    && curl -fsSL "https://gambi.2lp.in/api/packages/lumen/generic/kontur/nightly/kt-linux-amd64" -o /usr/local/bin/kt \
    && chmod +x /usr/local/bin/kt \
    && kt --version

ENV RUSTC_WRAPPER=/usr/local/bin/sccache
ENV SCCACHE_DIR=/root/.cache/sccache
ENV SCCACHE_CACHE_SIZE=50G

CMD ["bash"]
