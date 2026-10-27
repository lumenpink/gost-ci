FROM gambi.2lp.in/lumen/mirror-node:24-bookworm-slim

ENV DEBIAN_FRONTEND=noninteractive

RUN echo 'Acquire::Retries "5";' > /etc/apt/apt.conf.d/80-retries \
    && apt-get update && apt-get install -y --no-install-recommends \
    curl \
    ca-certificates \
    git \
    openssh-client \
    && rm -rf /var/lib/apt/lists/*

RUN npm install -g wrangler@latest \
    && node --version \
    && npm --version \
    && wrangler --version

CMD ["bash"]
