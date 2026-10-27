FROM gambi.2lp.in/lumen/mirror-node:24-bookworm-slim

ENV DEBIAN_FRONTEND=noninteractive

RUN echo 'Acquire::Retries "5";' > /etc/apt/apt.conf.d/80-retries \
    && apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    curl \
    ca-certificates \
    git \
    openssh-client \
    jq \
    && rm -rf /var/lib/apt/lists/*

ENV GO_VERSION=1.24.0
RUN curl -fsSL https://dl.google.com/go/go${GO_VERSION}.linux-amd64.tar.gz | tar -C /usr/local -xz

ENV GOPATH=/go
ENV PATH=$PATH:/usr/local/go/bin:$GOPATH/bin

RUN go version && node --version

CMD ["bash"]
