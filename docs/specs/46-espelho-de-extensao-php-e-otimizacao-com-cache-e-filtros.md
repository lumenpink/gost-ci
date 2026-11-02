# Especificação Técnica — Espelho de Extensão PHP e Otimização com Cache e Filtros (#46)

## 1. Contexto e Motivação
Na esteira de compilação da Run #1697, a injeção do `apt-cache` viabilizou o sucesso de 12 dos 13 jobs da matriz. Contudo, o job `Build & Push gost-ci-php` falhou porque o instalador invocou o PECL (`pecl.php.net`) sob a variável `$http_proxy`, direcionando requisições ao `apt-cacher-ng`, que rejeitou túneis e URLs externas com respostas 502 e 403.

Adicionalmente, a esteira executa todos os 13 jobs de forma incondicional a cada push no branch principal, sem verificar se os arquivos daquela imagem específica foram alterados, sobrecarregando a fila única do runner. O Kaniko tampouco mantinha cache de camadas remoto, forçando reconstruções integrais mesmo para camadas inalteradas.

## 2. Requisitos Técnicos

1. **Espelho Hermético da Extensão PECL (`mirror-pecl-xdebug`)**:
   - Criar e publicar no registry local a imagem estática `gambi.2lp.in/lumen/mirror-pecl-xdebug:3.5.3` (e `:latest`), empacotando o arquivo `xdebug-3.5.3.tgz` em `/xdebug.tgz`.
   - Adicionar o provisionamento do espelho em `scripts/sync-upstream-images.sh` e/ou script dedicado.
   - No `images/php/Dockerfile`, substituir o download externo por:
     ```dockerfile
     COPY --from=gambi.2lp.in/lumen/mirror-pecl-xdebug:3.5.3 /xdebug.tgz /tmp/xdebug.tgz
     RUN pecl install /tmp/xdebug.tgz \
         && docker-php-ext-enable xdebug \
         && rm -f /tmp/xdebug.tgz \
         && echo "xdebug.mode=off" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini \
         && echo "display_errors = Off" >> /usr/local/etc/php/conf.d/docker-php-display-errors.ini
     ```

2. **Filtro de Caminhos por Imagem no Workflow (`build-images.yml`)**:
   - Cada um dos 13 jobs deve inspecionar as alterações entre `${{ github.event.before }}` e `${{ github.sha }}` via `git diff --name-only`.
   - Se o evento for `workflow_dispatch`, se `github.event.before` for nulo/zerado, ou se houver alterações em `.forgejo/` ou no diretório específico da imagem (`images/<alvo>/`), a compilação via Kaniko deve ser executada.
   - Caso contrário, o job deve registrar a dispensa da compilação e finalizar graciosamente com sucesso imediato.

3. **Cache Remoto de Camadas no Kaniko**:
   - Em todas as chamadas do `/kaniko/executor`, incluir as opções de cache remoto:
     ```bash
     --cache=true --cache-repo=gambi.2lp.in/lumen/kaniko-cache --cache-ttl=168h
     ```

4. **Testes Automatizados e Auditoria de Mutação**:
   - Criar/atualizar script de validação estática e funcional em `tests/` cobrindo:
     - Existência da cópia do espelho hermético no Dockerfile do PHP;
     - Presença das flags de cache do Kaniko em todos os jobs do workflow;
     - Presença da lógica de detecção de mudanças (filtro de caminhos) nos jobs;
     - Testes de mutação verificando a detecção de ausência dessas diretivas.

## 3. Status e Resultados
- Status: Concluído e Fechado (Fase 9).
- Imagem de espelho `gambi.2lp.in/lumen/mirror-pecl-xdebug:3.5.3` publicada no registry local.
- Dockerfile do PHP atualizado para consumo hermético sem chamadas de rede externas ao `pecl.php.net`.
- Filtro de caminhos via `git diff` implementado em todos os 13 jobs do workflow `build-images.yml`.
- Cache de camadas ativado com `--cache=true --cache-repo=gambi.2lp.in/lumen/kaniko-cache --cache-ttl=168h`.
- Suite completa de testes automatizados e testes de mutação aprovados.
- Auditoria de qualidade `cccp check --strict` aprovada com 100% de conformidade.
