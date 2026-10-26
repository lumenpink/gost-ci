FROM gambi.2lp.in/lumen/gost-ci-rust:latest

# Pré-carregar dependências canônicas do Lauda (ishcondidim, papeli, urupema)
# para garantir testes herméticos sem acesso à rede em tempo de CI
RUN mkdir -p /opt/gost/deps && \
    git clone --depth 1 https://gambi.2lp.in/lumen/ishcondidim.git /opt/gost/deps/ishcondidim && \
    git clone --depth 1 https://gambi.2lp.in/lumen/papeli.git /opt/gost/deps/papeli && \
    git clone --depth 1 https://gambi.2lp.in/lumen/urupema.git /opt/gost/deps/urupema && \
    cd /opt/gost/deps/ishcondidim && cargo check && \
    cd /opt/gost/deps/papeli && cargo check && \
    cd /opt/gost/deps/urupema && cargo check

CMD ["bash"]
