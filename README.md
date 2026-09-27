# gost-ci

Matriz de containers especializados e otimizados de CI/CD para projetos sob a norma GOST.

## 📋 Conformidade GOST

Este projeto adota a norma **[GOST](https://codeberg.org/lumenpink/gost)** (Gosplan Standard for Technical Software).
- **Versão GOST:** `1.1.0`
- **Linguagens declaradas:** `shell`
- **Licença de Código:** `Apache-2.0`
- **Licença de Marca/Logo:** `CC-BY-ND-4.0`

## 📦 Matriz de Imagens

| Imagem | Base | Ambiente & Versões | Propósito Principal |
| :--- | :--- | :--- | :--- |
| **`gost-ci-rust`** | `debian:bookworm-slim` | Rust `1.98.1` (stable), `cargo`, `rustfmt`, `clippy`, `build-essential`, `git` | Pipeline de verificação: `cargo check`, `cargo test`, `fmt` e `clippy` |
| **`gost-ci-cross`** | `debian:bookworm-slim` | Rust `1.98.1`, targets `x86_64`, `i686`, `armv7` + `gcc-multilib`, `gcc-arm-linux-gnueabihf`, `tar` | Compilação cruzada e empacotamento multi-arquitetura (`build-release`, `publish-nightly`) |
| **`gost-ci-deploy`** | `node:24-bookworm-slim` | Node.js `24`, `npm`, `wrangler@latest`, `git`, `curl` | Entrega de documentação e sites estáticos (Cloudflare Workers / Codeberg Pages) |

## 🛠️ Como Consumir em Workflows Forgejo / GitHub Actions

### 1. Testes e Auditoria Rust (`gost-ci-rust`)

```yaml
jobs:
  test:
    name: "Rust — Tests & Checks"
    runs-on: ubuntu-latest
    container:
      image: lumenpink/gost-ci-rust:latest
    steps:
      - name: "Checkout"
        uses: https://github.com/actions/checkout@v4

      - name: "Cargo Check"
        run: cargo check --verbose

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
      image: lumenpink/gost-ci-cross:latest
    steps:
      - name: "Checkout"
        uses: https://github.com/actions/checkout@v4

      - name: "Build Multi-Target"
        run: |
          cargo build --release
          cargo build --release --target i686-unknown-linux-gnu
          cargo build --release --target armv7-unknown-linux-gnueabihf
```

### 3. Deploy de Documentação (`gost-ci-deploy`)

```yaml
jobs:
  deploy-site:
    name: "Deploy Documentation Site"
    runs-on: ubuntu-latest
    container:
      image: lumenpink/gost-ci-deploy:latest
    steps:
      - name: "Checkout"
        uses: https://github.com/actions/checkout@v4

      - name: "Publish Site"
        run: wrangler deploy
```

## 📄 Licenciamento

- **Código & Scripts:** [Apache-2.0](./LICENSE)
- **Marca e Logotipo:** [CC-BY-ND-4.0](./LICENSE-LOGO)
