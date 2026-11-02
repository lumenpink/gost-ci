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
    python3 \
    python3-pip \
    python3-venv \
    python3-dev \
    build-essential \
    curl \
    ca-certificates \
    git \
    openssh-client \
    jq \
    && rm -f /etc/apt/apt.conf.d/01proxy \
    && rm -rf /var/lib/apt/lists/*

RUN ln -sf /usr/bin/python3 /usr/bin/python \
    && python --version \
    && node --version

CMD ["bash"]
