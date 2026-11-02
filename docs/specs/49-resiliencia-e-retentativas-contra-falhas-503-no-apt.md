# Especificação Técnica — Resiliência e Retentativas contra Falhas 503 no APT (#49)

## 1. Contexto e Motivação
Na esteira de compilação da Run #1721, a etapa `Build & Push gost-ci-deploy` falhou após o proxy de cache local `http://172.17.0.1:3142` retornar erros `503 Connection timeout` e `500 Remote or cache error` ao tentar acessar espelhos de `deb.debian.org/debian bookworm-updates`. Com a falha de download das listas de índices, o comando `apt-get install` falhou com broken packages (código 100).
Para evitar falhas na esteira por indisponibilidade transitória do proxy ou timeout upstream, o APT deve dispor de retentativas dedicadas de transporte HTTP/HTTPS e estratégia de recuperação com tentativa direta em caso de erro no proxy.

## 2. Requisitos Técnicos
1. **Configuração Explícita de Retentativas HTTP/HTTPS no APT**:
   - Em todos os 12 Dockerfiles que usam `apt-get`, configurar em `/etc/apt/apt.conf.d/80-retries`:
     ```text
     Acquire::http::Retries "5";
     Acquire::https::Retries "5";
     ```
2. **Estratégia de Recuperação e Fallback no `apt-get update`**:
   - Em caso de falha transitória na atualização dos índices via proxy, executar fallback automático:
     ```bash
     (apt-get update || (sleep 3 && rm -f /etc/apt/apt.conf.d/01proxy && apt-get update))
     ```
3. **Validação Automatizada e Mutação**:
   - Atualizar `tests/test-apt-retries.sh` para verificar a presença de `Acquire::http::Retries` e o mecanismo de fallback/retry em todos os Dockerfiles com `apt-get`.
   - Adicionar testes de mutação cobrindo a ausência dessas diretivas.

## 3. Status e Resultados
- Status: Concluído e Fechado (Fase 9).
- Diretivas `Acquire::http::Retries "5"` e `Acquire::https::Retries "5"` injetadas em todos os 12 Dockerfiles.
- Fallback automático para atualização direta adicionado no `apt-get update`.
- Testes automatizados e testes de mutação aprovados em `tests/test-apt-retries.sh`.
- Auditoria estrita `cccp check --strict` aprovada com 100% de conformidade.
