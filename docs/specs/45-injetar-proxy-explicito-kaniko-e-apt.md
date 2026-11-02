# Especificação Técnica — Injeção Explícita de Proxy de Cache no Kaniko e APT (#45)

## 1. Contexto e Motivação
Na esteira de compilação de imagens (`build-images.yml`), as etapas que executam via Kaniko rodam em containers de ação isolados que não herdam o ambiente do runner sem declaração explícita. A expansão de `${http_proxy:-}` gerava strings vazias, fazendo com que imagens baseadas em Debian Trixie tentassem conexões diretas para `deb.debian.org:80`, sofrendo timeouts externos.

## 2. Requisitos Técnicos
1. **Configuração Explícita no Workflow (`build-images.yml`)**:
   - O workflow deve declarar variáveis de ambiente globais:
     ```yaml
     env:
       http_proxy: "http://172.17.0.1:3142"
       HTTP_PROXY: "http://172.17.0.1:3142"
     ```
   - Cada chamada ao `/kaniko/executor` deve passar explicitamente:
     ```bash
     --build-arg http_proxy="http://172.17.0.1:3142" --build-arg HTTP_PROXY="http://172.17.0.1:3142"
     ```
2. **Injeção Temporária de Proxy no APT nos Dockerfiles**:
   - Todo Dockerfile em `images/` que invoca `apt-get` deve configurar temporariamente o proxy do APT no início da camada `RUN`:
     ```text
     ([ -n "$http_proxy" ] && echo "Acquire::http::Proxy \"$http_proxy\";" > /etc/apt/apt.conf.d/01proxy || true)
     ```
   - E garantir a remoção de `/etc/apt/apt.conf.d/01proxy` antes do término da mesma instrução `RUN`, para não gravar IPs locais na imagem final.
3. **Auditoria Automatizada e Testes**:
   - `tests/test-apt-retries.sh` deve validar a presença da configuração temporária do proxy em todos os Dockerfiles e o repasse explícito do IP do proxy no workflow.

## 3. Status e Resultados
- Status: Concluído e Fechado (Fase 9).
- Proxy `http://172.17.0.1:3142` injetado no `env:` global e nas 13 chamadas do Kaniko em `build-images.yml`.
- Injeção dinâmica de `01proxy` e limpeza pós-instalação configurada em 12 Dockerfiles.
- 4 testes de mutação e auditoria estrita `cccp check --strict` aprovados com 100% de conformidade.
