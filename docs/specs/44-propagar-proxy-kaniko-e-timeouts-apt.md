# Especificação Técnica — Propagação de Proxy no Kaniko e Timeouts do APT (#44)

## 1. Contexto e Problema
A esteira de CI do Forgejo injeta no runner a variável de proxy de cache local `http_proxy=http://172.17.0.1:3142` (`apt-cache`). Contudo, o executor Kaniko (`gcr.io/kaniko-project/executor:debug`) não propaga automaticamente variáveis de ambiente para as etapas `RUN` do Dockerfile sem a declaração explícita de `--build-arg`.

Como resultado:
1. As instruções `apt-get` executadas durante o build das imagens tentavam conectar-se diretamente aos servidores externos de `deb.debian.org:80`, ignorando o cache local.
2. Oscilações transitórias na conexão com os espelhos Debian externos causavam falhas no build com erro `exit status 100` (`Unable to connect to deb.debian.org:80`).

## 2. Requisitos e Diretivas
1. **Propagação de Proxy no Kaniko**:
   - Todas as 13 invocações de `/kaniko/executor` em `.forgejo/workflows/build-images.yml` devem receber explicitamente os argumentos:
     ```bash
     --build-arg http_proxy="${http_proxy:-}" --build-arg HTTP_PROXY="${http_proxy:-}"
     ```
   - O proxy só será utilizado quando a variável de ambiente estiver definida no container do executor, mantendo compatibilidade quando executado isoladamente sem proxy.
2. **Timeouts Defensivos no APT**:
   - Todo Dockerfile em `images/` que utilize `apt-get` deve configurar explicitamente timeouts de rede de 60 segundos no arquivo `/etc/apt/apt.conf.d/80-retries`:
     ```text
     Acquire::http::Timeout "60";
     Acquire::https::Timeout "60";
     ```
3. **Validação Automatizada e Testes**:
   - O script `tests/test-apt-retries.sh` deve auditar:
     - Presença de `Acquire::http::Timeout` nos Dockerfiles que utilizam `apt-get`.
     - Presença obrigatória de `--build-arg http_proxy` em cada job do Kaniko em `.forgejo/workflows/build-images.yml`.
   - Adicionar mutante para garantir que a remoção de qualquer um dos argumentos falhe o teste.

## 3. Status e Resultados
- Status: Aprovado e Validado na Fase 8.
- 13 invocações do Kaniko atualizadas com `--build-arg http_proxy` e `HTTP_PROXY`.
- 12 Dockerfiles atualizados com timeouts de 60s no APT.
- Bateria de testes e mutantes aprovada com 100% de conformidade no Gosplan Quality Gate.
