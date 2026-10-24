# Changelog

## [Unreleased]

### Features
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

