# Especificação Técnica — Resiliência de Rede APT nos Dockerfiles (#35)

## 1. Contexto e Problema
Durante a execução de compilações de containers via Kaniko na CI (`gost-ci`), o job `build-gui` (e potencialmente outros containers com alto número de pacotes Debian) pode falhar devido a instabilidades transitórias de rede na conexão com os servidores upstream (`deb.debian.org:80` ou espelhos de segurança), gerando erros como:
```text
E: Failed to fetch http://deb.debian.org/... Unable to connect to deb.debian.org:80
E: Unable to fetch some archives, maybe run apt-get update or try with --fix-missing?
```

## 2. Requisitos e Diretivas
1. **Configuração de Retries**:
   - Todo `Dockerfile` que invoca `apt-get` deve configurar explicitamente retries para requisições HTTP/HTTPS via `Acquire::Retries "5";` no APT (ex: criando `/etc/apt/apt.conf.d/80-retries` ou flag direta).
2. **Resiliência e Idempotência**:
   - Manter `--no-install-recommends` e limpeza de `/var/lib/apt/lists/*`.
   - Adicionar `--fix-missing` nas invocações `apt-get install` mais críticas.
3. **Auditoria Automatizada**:
   - Um teste automatizado (`tests/test-apt-retries.sh`) deve validar que todos os Dockerfiles em `images/` que utilizam `apt-get` possuem a configuração de resiliência `Acquire::Retries` configurada.
