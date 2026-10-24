FROM gambi.2lp.in/lumen/mirror-php:8.4-cli

ENV DEBIAN_FRONTEND=noninteractive

# Instalador otimizado de extensões oficiais PHP
COPY --from=mlocati/php-extension-installer /usr/bin/install-php-extensions /usr/local/bin/

# Dependências de sistema e Node.js 22 LTS (para suporte hermético a actions no Forgejo/act)
RUN apt-get update && apt-get install -y --no-install-recommends \
        git \
        unzip \
        curl \
        ca-certificates \
        jq \
    && curl -fsSL https://deb.nodesource.com/setup_22.x | bash - \
    && apt-get install -y --no-install-recommends nodejs \
    && rm -rf /var/lib/apt/lists/*

# Instalar extensões necessárias para testes, geração de assets e CLI
RUN install-php-extensions gd zip exif sqlite3 pcntl intl

# Xdebug — instalado e configurado como off por padrão (ativável via XDEBUG_MODE=coverage)
RUN pecl install xdebug \
    && docker-php-ext-enable xdebug \
    && echo "xdebug.mode=off" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini \
    && echo "display_errors = Off" >> /usr/local/etc/php/conf.d/docker-php-display-errors.ini \
    && rm -rf /tmp/pear

# Composer 2 oficial hermético
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

RUN php --version \
    && composer --version \
    && node --version

CMD ["bash"]
