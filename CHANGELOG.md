# Changelog

## [Unreleased]

### Fixes
  - (cross) remover linker musl-gcc em alvos musl x86_64 para evitar SIGSEGV (closes #42)
  - (images) estabilizar php com install-php-extensions, resiliencia sccache e condensar readme (closes #41)
  - (images) isolar dependencias de php e dioxus em espelhos e pacotes locais (closes #40)
  - (cross) instalar binario nativo linux-amd64 do cccp da Generic Package (closes #39)
  - (cross) usar script portatil cccp.sh para evitar mismatch de libc (closes #38)
  - (android) usar base soberana mirror-node trixie com node 24 nativo (#33)

### Features
  - (cross) incluir utilitario cccp nas imagens gost-ci-cross e gost-ci-rust (closes #37)
  - (cross) adicionar cmake na imagem gost-ci-cross para libgit2 (closes #29)
  - (images) adicionar sub-imagens atomicas gost-ci-python e gost-ci-go (closes #28)
  - (wasm) pre-instalar wasm-bindgen, wasm-opt e esbuild (closes #22)
  - (ci) publicar no registry gambi e remover dockerhub (closes #21)
  - (images) criar espelho de imagens upstream e referenciá-las (closes #23)
  - (docker) garantir tags canonicas para todas as imagens (closes #19)
  - (packages) auditar e garantir versao canonica nos workflows (closes #18)
  - (images) adicionar sccache v0.18.0 nas imagens rust, wasm, cross e gui (closes #20)
  - (images) adicionar libxdo-dev nas imagens cross e gui para linkagem desktop (closes #17)
  - (ci) atualizar rust para 1.99.1 e incluir bibliotecas desktop gui (closes #16)
  - (cross) incluir rustfmt e clippy hermeticos na imagem gost-ci-cross (closes #15)
  - (ci) migrar publicacao de containers para Docker Hub (closes #14)
  - (cross) adicionar suporte a alvos multiarch aarch64, musl e windows mingw (closes #13)
  - (images) criar imagem gost-ci-gui com WebKitGTK e áudio para aplicações desktop (resolves #8)
  - (images) criar imagem gost-ci-php com PHP 8.4, Composer e extensões de QA (resolves #7)
  - (images) criar imagem gost-ci-shell com shellspec, shellcheck e shfmt (resolves #6)
  - (images) criar imagem gost-ci-wasm com toolchain Rust e wasm-pack (resolves #5)
  - (infra) bootstrap gost-ci repository and specialized container matrix (closes #1)

## Previous Releases

