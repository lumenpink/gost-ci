# gost-ci

Matriz de containers especializados e otimizados de CI/CD para projetos sob a norma GOST.

## 📋 Conformidade GOST

Este projeto adota a norma **[GOST](https://codeberg.org/lumenpink/gost)** (Gosplan Standard for Technical Software).
- **Versão GOST:** `1.1.0`
- **Linguagens declaradas:** `shell`
- **Licença de Código:** `Apache-2.0`
- **Licença de Marca/Logo:** `CC-BY-ND-4.0`

## 📦 Matriz de Imagens Especializadas

| Imagem | Base | Ambiente & Versões | Propósito Principal |
| :--- | :--- | :--- | :--- |
| **`gost-ci-rust`** | `node:24-bookworm-slim` | Rust `1.99.1` (stable), `cargo`, `rustfmt`, `clippy`, `build-essential`, `git` | Pipeline de verificação: `cargo check`, `cargo test`, `fmt` e `clippy` |
| **`gost-ci-cross`** | `node:24-bookworm-slim` | Rust `1.99.1`, targets `x86_64` (gnu/musl), `aarch64` (gnu/musl), `windows` (mingw), `i686`, `armv7` + `musl-tools`, `cargo-zigbuild`, `zig`, `libglib2.0-dev`, `libwebkit2gtk-4.1-dev`, `libasound2-dev`, `libxdo-dev` | Compilação cruzada e empacotamento multi-arquitetura soberano (`build-release`, `publish-nightly`) |
| **`gost-ci-deploy`** | `node:24-bookworm-slim` | Node.js `24`, `npm`, `wrangler@latest`, `git`, `curl` | Entrega de documentação e sites estáticos (Cloudflare Workers / Codeberg Pages) |
| **`gost-ci-wasm`** | `node:24-bookworm-slim` | Rust `1.99.1`, target `wasm32-unknown-unknown`, `wasm-pack` `v0.13.1` | Compilação hermética de aplicações WebAssembly (`navalha`, `kokorosim`) |
| **`gost-ci-shell`** | `node:24-bookworm-slim` | `shellspec` `0.28.1`, `shfmt` `v3.10.0`, `shellcheck`, `bash`, `git`, `jq` | Testes BDD e análise estática hermética de scripts shell (`cccp`) |
| **`gost-ci-php`** | `php:8.4-cli` | PHP `8.4`, `composer:2`, extensões (`gd`, `zip`, `exif`, `sqlite3`, `pcntl`, `intl`), `xdebug`, Node `22` | Testes unitários (Pest), análise de código (Pint, Psalm) e auditoria (`indieinabox`, `fuxico`) |
| **`gost-ci-gui`** | `node:24-bookworm-slim` | Rust `1.99.1`, `libglib2.0-dev`, `libwebkit2gtk-4.1-dev`, `libasound2-dev`, `libxdo-dev`, `build-essential` | Compilação e testes de aplicações desktop Linux (`lacraia`) |
| **`gost-ci-flutter`** | `debian:bookworm-slim` | Flutter `stable`, OpenJDK `17`, Android SDK `34`, `build-tools;34.0.0` | Compilação hermética e determinística de APKs Android/Flutter (`mocambo`) |

## 🛠️ Como Consumir em Workflows Forgejo / GitHub Actions

### 1. Testes e Auditoria Rust (`gost-ci-rust`)

```yaml
jobs:
  test:
    name: "Rust — Tests & Checks"
    runs-on: ubuntu-latest
    container:
      image: gambi.2lp.in/lumen/gost-ci-rust:latest
    steps:
      - name: "Checkout"
        uses: https://github.com/actions/checkout@v4
      - name: "Cargo Test"
        run: cargo test --verbose
```

### 2. Compilação Cruzada Multi-Arquitetura (`gost-ci-cross`)

```yaml
jobs:
  build-release:
    name: "Rust — Release Binaries"
    runs-on: ubuntu-latest
    container:
      image: gambi.2lp.in/lumen/gost-ci-cross:latest
    steps:
      - name: "Checkout"
        uses: https://github.com/actions/checkout@v4
      - name: "Build Multi-Target"
        run: |
          # Linux x86_64 Estático
          cargo build --release --target x86_64-unknown-linux-musl
          # Linux ARM64 Estático
          cargo build --release --target aarch64-unknown-linux-musl
          # Windows x86_64
          cargo build --release --target x86_64-pc-windows-gnu
```

### 3. Deploy de Documentação & WebApps (`gost-ci-deploy`)

```yaml
jobs:
  deploy-site:
    name: "Deploy Documentation Site"
    runs-on: ubuntu-latest
    container:
      image: gambi.2lp.in/lumen/gost-ci-deploy:latest
    steps:
      - name: "Checkout"
        uses: https://github.com/actions/checkout@v4
      - name: "Publish Site"
        run: wrangler deploy
```

### 4. Compilação WebAssembly (`gost-ci-wasm`)

```yaml
jobs:
  build-wasm:
    name: "Build Wasm Bundle"
    runs-on: ubuntu-latest
    container:
      image: gambi.2lp.in/lumen/gost-ci-wasm:latest
    steps:
      - name: "Checkout"
        uses: https://github.com/actions/checkout@v4
      - name: "Compile Wasm"
        run: wasm-pack build --target web --out-dir dist/pkg
```

### 5. Validação e Testes Shell (`gost-ci-shell`)

```yaml
jobs:
  test-shell:
    name: "Shell Quality & Spec"
    runs-on: ubuntu-latest
    container:
      image: gambi.2lp.in/lumen/gost-ci-shell:latest
    steps:
      - name: "Checkout"
        uses: https://github.com/actions/checkout@v4
      - name: "ShellCheck"
        run: shellcheck scripts/*.sh
      - name: "ShellSpec"
        run: shellspec --format documentation
```

### 6. Testes PHP & Composer (`gost-ci-php`)

```yaml
jobs:
  test-php:
    name: "PHP 8.4 Tests"
    runs-on: ubuntu-latest
    container:
      image: gambi.2lp.in/lumen/gost-ci-php:latest
    steps:
      - name: "Checkout"
        uses: https://github.com/actions/checkout@v4
      - name: "Install Deps"
        run: composer install --prefer-dist --no-progress
      - name: "Run Pest"
        run: ./vendor/bin/pest
```

### 7. Aplicações Desktop WebKitGTK (`gost-ci-gui`)

```yaml
jobs:
  build-gui:
    name: "Rust GUI Desktop"
    runs-on: ubuntu-latest
    container:
      image: gambi.2lp.in/lumen/gost-ci-gui:latest
    steps:
      - name: "Checkout"
        uses: https://github.com/actions/checkout@v4
      - name: "Cargo Build"
        run: cargo build --release
```

## 📄 Licenciamento

- **Código & Scripts:** [Apache-2.0](./LICENSE)
- **Marca e Logotipo:** [CC-BY-ND-4.0](./LICENSE-LOGO)
- **Mídias e Ilustrações:** [CC-BY-SA-4.0](./LICENSE-MEDIA)
