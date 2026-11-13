FROM gambi.2lp.in/lumen/mirror-node:24-bookworm-slim

ENV DEBIAN_FRONTEND=noninteractive
ENV SHELLSPEC_VERSION=0.28.1
ENV SHFMT_VERSION=v3.10.0

RUN echo 'Acquire::Retries "5";' > /etc/apt/apt.conf.d/80-retries \
    && echo 'Acquire::http::Timeout "60";' >> /etc/apt/apt.conf.d/80-retries \
    && echo 'Acquire::https::Timeout "60";' >> /etc/apt/apt.conf.d/80-retries \
    && echo 'Acquire::http::Retries "5";' >> /etc/apt/apt.conf.d/80-retries \
    && echo 'Acquire::https::Retries "5";' >> /etc/apt/apt.conf.d/80-retries \
    && ([ -n "$http_proxy" ] && echo "Acquire::http::Proxy \"$http_proxy\";" > /etc/apt/apt.conf.d/01proxy || true) \
    && (apt-get update || (sleep 3 && rm -f /etc/apt/apt.conf.d/01proxy && apt-get update)) \
    && apt-get install -y --no-install-recommends \
    bash \
    git \
    openssh-client \
    file \
    curl \
    ca-certificates \
    jq \
    shellcheck \
    procps \
    tar \
    gzip \
    && rm -f /etc/apt/apt.conf.d/01proxy \
    && rm -rf /var/lib/apt/lists/*

# Instalar shfmt (binário estático oficial)
RUN curl -fsSL "https://github.com/mvdan/sh/releases/download/${SHFMT_VERSION}/shfmt_${SHFMT_VERSION}_linux_amd64" \
    -o /usr/local/bin/shfmt \
    && chmod +x /usr/local/bin/shfmt \
    && shfmt --version

# Instalar shellspec (release oficial sem dependência de internet em tempo de execução)
RUN mkdir -p /opt/shellspec \
    && curl -fsSL "https://github.com/shellspec/shellspec/archive/refs/tags/${SHELLSPEC_VERSION}.tar.gz" \
    | tar -xz -C /opt/shellspec --strip-components=1 \
    && ln -s /opt/shellspec/shellspec /usr/local/bin/shellspec \
    && shellspec --version

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
    && gn --version

CMD ["bash"]
