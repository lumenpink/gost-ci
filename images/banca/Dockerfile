FROM gambi.2lp.in/lumen/mirror-node:24-bookworm-slim

ENV DEBIAN_FRONTEND=noninteractive

# Dependências canônicas da Banca / Pratilera F-Droid:
# - bash, git, file, curl, ca-certificates, jq (ferramentas de build e inspeção)
# - openjdk-17-jdk-headless (jarsigner para assinatura de index-v1.jar)
# - python3, python3-pil (geração do site e sanitização de ícones para 8-bit RGBA)
# - aapt (extração determinística de metadados dos APKs)
RUN apt-get update && apt-get install -y --no-install-recommends \
    bash \
    git \
    file \
    curl \
    ca-certificates \
    jq \
    openjdk-17-jdk-headless \
    python3 \
    python3-pil \
    aapt \
    && rm -rf /var/lib/apt/lists/*

CMD ["bash"]
