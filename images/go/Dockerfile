FROM gambi.2lp.in/lumen/mirror-node:24-bookworm-slim

ENV DEBIAN_FRONTEND=noninteractive

RUN echo 'Acquire::Retries "5";' > /etc/apt/apt.conf.d/80-retries \
    && echo 'Acquire::http::Timeout "60";' >> /etc/apt/apt.conf.d/80-retries \
    && echo 'Acquire::https::Timeout "60";' >> /etc/apt/apt.conf.d/80-retries \
    && echo 'Acquire::http::Retries "5";' >> /etc/apt/apt.conf.d/80-retries \
    && echo 'Acquire::https::Retries "5";' >> /etc/apt/apt.conf.d/80-retries \
    && ([ -n "$http_proxy" ] && echo "Acquire::http::Proxy \"$http_proxy\";" > /etc/apt/apt.conf.d/01proxy || true) \
    && (apt-get update || (sleep 3 && rm -f /etc/apt/apt.conf.d/01proxy && apt-get update)) \
    && apt-get install -y --no-install-recommends \
    build-essential \
    curl \
    ca-certificates \
    git \
    openssh-client \
    jq \
    && rm -f /etc/apt/apt.conf.d/01proxy \
    && rm -rf /var/lib/apt/lists/*

ENV GO_VERSION=1.24.0
RUN curl -fsSL https://dl.google.com/go/go${GO_VERSION}.linux-amd64.tar.gz | tar -C /usr/local -xz

ENV GOPATH=/go
ENV PATH=$PATH:/usr/local/go/bin:$GOPATH/bin

RUN go version && node --version

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
