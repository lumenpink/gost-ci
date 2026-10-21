# Spec 16: Atualização para Rust 1.99.1 e Bibliotecas Desktop GUI na Imagem gost-ci-cross

## 1. Contexto e Motivação
A esteira de compilação e teste do ecossistema soberano Lumen deve operar com a versão estável mais moderna do compilador Rust (`1.99.1`). Além disso, aplicações com interface gráfica (egui, ratatui com backend avançado, Dioxus Desktop com WebKitGTK) exigem a presença de cabeçalhos de desenvolvimento C do sistema host (`glib-2.0`, `webkit2gtk-4.1`, `asound2`) para execução hermética sem requisições ad-hoc a repositórios de pacotes em tempo de execução.

## 2. Requisitos Técnicos
1. **Atualização Global do Toolchain Rust:**
   Definir `ENV RUST_VERSION=1.99.1` em:
   - `images/cross/Dockerfile`
   - `images/rust/Dockerfile`
   - `images/gui/Dockerfile`
   - `images/wasm/Dockerfile`
2. **Tags de Imagem no Pipeline:**
   Atualizar as tags específicas no workflow `.forgejo/workflows/build-images.yml` de `:1.98.1` para `:1.99.1`.
3. **Bibliotecas C Desktop/GUI em gost-ci-cross:**
   Adicionar ao `images/cross/Dockerfile`:
   - `libglib2.0-dev`
   - `libwebkit2gtk-4.1-dev`
   - `libasound2-dev`
4. **Verificação de Conformidade em Testes:**
   Atualizar `tests/test-cross-multiarch.sh` e suites de teste para garantir a detecção e conformidade estrita da versão `1.99.1` e das novas bibliotecas GUI.
