FROM gambi.2lp.in/lumen/gost-ci-rust:latest

# Instalar binários canônicos pré-compilados dos satélites (ishcondidim, papeli, urupema)
# gerados e publicados diretamente pelas suas respectivas esteiras de CI (#50)
RUN curl -fsSL --retry 5 --retry-connrefused --retry-delay 2 "https://gambi.2lp.in/lumen/ishcondidim/releases/download/latest/ishcondidim" -o /usr/local/bin/ishcondidim \
    && chmod +x /usr/local/bin/ishcondidim \
    && curl -fsSL --retry 5 --retry-connrefused --retry-delay 2 "https://gambi.2lp.in/lumen/papeli/releases/download/latest/papeli" -o /usr/local/bin/papeli \
    && chmod +x /usr/local/bin/papeli \
    && curl -fsSL --retry 5 --retry-connrefused --retry-delay 2 "https://gambi.2lp.in/lumen/urupema/releases/download/latest/urupema" -o /usr/local/bin/urupema \
    && chmod +x /usr/local/bin/urupema

# Ferramentas Canônicas do Ecossistema de Dev (Governança, Regras e Catálogo)
ARG CCCP_CACHEBUST=1
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
