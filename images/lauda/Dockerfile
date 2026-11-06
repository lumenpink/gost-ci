FROM gambi.2lp.in/lumen/gost-ci-rust:latest

# Instalar binários canônicos pré-compilados dos satélites (ishcondidim, papeli, urupema)
# gerados e publicados diretamente pelas suas respectivas esteiras de CI (#50)
RUN curl -fsSL --retry 5 --retry-connrefused --retry-delay 2 "https://gambi.2lp.in/lumen/ishcondidim/releases/download/latest/ishcondidim" -o /usr/local/bin/ishcondidim \
    && chmod +x /usr/local/bin/ishcondidim \
    && curl -fsSL --retry 5 --retry-connrefused --retry-delay 2 "https://gambi.2lp.in/lumen/papeli/releases/download/latest/papeli" -o /usr/local/bin/papeli \
    && chmod +x /usr/local/bin/papeli \
    && curl -fsSL --retry 5 --retry-connrefused --retry-delay 2 "https://gambi.2lp.in/lumen/urupema/releases/download/latest/urupema" -o /usr/local/bin/urupema \
    && chmod +x /usr/local/bin/urupema

CMD ["bash"]
