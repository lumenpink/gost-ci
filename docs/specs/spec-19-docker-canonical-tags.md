# Especificação Técnica — Auditoria e Tags Canônicas das Imagens Docker (#19)

## 1. Contexto e Motivação
No ecossistema GOST, todas as imagens de contêiner publicadas em registros OCI (Docker Hub e Forgejo Registry) devem garantir reprodutibilidade hermética de compilação e execução. A utilização exclusiva da tag móvel `:latest` é vedada para builds imutáveis, sendo mandatória a geração simultânea de uma tag estável canônica correspondente à versão do toolchain ou runtime base.

Foi verificado que as imagens `gost-ci-lauda`, `gost-ci-banca` e `gost-ci-flutter` estavam sendo construídas no workflow `.forgejo/workflows/build-images.yml` apenas com o destino `:latest`, sem a respectiva tag canônica de versão.

## 2. Requisitos Mandatórios de Tags Canônicas

### 2.1 Matriz de Tags Canônicas por Imagem
Cada imagem do catálogo `gost-ci` DEVE possuir, no mínimo, as seguintes tags:

1. **`gost-ci-rust`**:
   - Tag móvel: `:latest`
   - Tag canônica: `:1.99.1` (Toolchain Rust estável)
2. **`gost-ci-cross`**:
   - Tag móvel: `:latest`
   - Tag canônica: `:1.99.1` (Toolchain Rust + Zig / cross-compilação)
3. **`gost-ci-deploy`**:
   - Tag móvel: `:latest`
   - Tag canônica: `:node24` (Node.js 24 LTS / deploy Cloudflare & tooling)
4. **`gost-ci-wasm`**:
   - Tag móvel: `:latest`
   - Tag canônica: `:1.99.1` (Rust + wasm-pack)
5. **`gost-ci-shell`**:
   - Tag móvel: `:latest`
   - Tag canônica: `:0.28.1` (ShellSpec / ShellCheck / shfmt)
6. **`gost-ci-php`**:
   - Tag móvel: `:latest`
   - Tag canônica: `:8.4` (PHP 8.4 CLI + extensões QA)
7. **`gost-ci-gui`**:
   - Tag móvel: `:latest`
   - Tag canônica: `:1.99.1` (Rust + WebKitGTK / libxdo-dev)
8. **`gost-ci-lauda`**:
   - Tag móvel: `:latest`
   - Tag canônica: `:1.99.1` (Compilação soberana Lauda / Rust 1.99.1)
9. **`gost-ci-banca`**:
   - Tag móvel: `:latest`
   - Tag canônica: `:node24` (Ambiente Node 24 + JDK + ferramentas Android/FDroid)
10. **`gost-ci-flutter`**:
    - Tag móvel: `:latest`
    - Tag canônica: `:android34` (Android SDK 34 + Flutter stable)

### 2.2 Auditoria Contínua
Nenhuma imagem Docker listada no repositório `gost-ci` pode ser aprovada sem teste automatizado que garanta que seu job Kaniko contenha tanto `:latest` quanto a tag canônica esperada.

## 3. Critérios de Aceite
1. O script `tests/test-docker-canonical-tags.sh` deve auditar as 10 imagens e garantir que todas possuem `:latest` e a tag canônica correspondente.
2. Testes de mutação devem validar que a remoção de uma tag canônica resulta em falha imediata da esteira de qualidade.
