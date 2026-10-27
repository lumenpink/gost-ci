FROM gambi.2lp.in/lumen/mirror-node:24-bookworm-slim

ENV DEBIAN_FRONTEND=noninteractive
ENV SHELLSPEC_VERSION=0.28.1
ENV SHFMT_VERSION=v3.10.0

RUN echo 'Acquire::Retries "5";' > /etc/apt/apt.conf.d/80-retries \
    && apt-get update && apt-get install -y --no-install-recommends \
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

CMD ["bash"]
