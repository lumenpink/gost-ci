# gost-ci

Matriz de contêineres especializados e otimizados de CI/CD para projetos sob a norma GOST.

## 📋 Conformidade GOST

Este projeto adota a norma **[GOST](https://codeberg.org/lumenpink/gost)** (Gosplan Standard for Technical Software).
- **Versão GOST:** `1.1.0`
- **Linguagens declaradas:** `shell`
- **Licença de Código:** `Apache-2.0`
- **Licença de Marca/Logo:** `CC-BY-ND-4.0`

## 📦 Matriz de Imagens Especializadas

As imagens oficiais são publicadas no registro `gambi.2lp.in/lumen/`:

- **`gost-ci-rust`**: Verificação, testes e auditoria `cargo` e `cccp check`.
- **`gost-ci-cross`**: Compilação cruzada multi-alvo (Linux, Windows, ARM, Musl).
- **`gost-ci-deploy`**: Entrega contínua de sites e documentação (Cloudflare Workers / Pages).
- **`gost-ci-wasm`**: Compilação hermética de aplicações WebAssembly (`wasm-pack`).
- **`gost-ci-shell`**: Análise e testes BDD em shell (`shellspec`, `shellcheck`, `shfmt`).
- **`gost-ci-php`**: Testes unitários PHP 8.4 e Composer (`pest`, `xdebug`).
- **`gost-ci-gui`**: Aplicações desktop Linux (`libwebkit2gtk`, `libxdo`).
- **`gost-ci-flutter`**: Compilação determinística de APKs Android/Flutter.

Consulte o catálogo completo e exemplos de workflows em [docs/catalogo-de-imagens.md](docs/catalogo-de-imagens.md).

## 📄 Licenciamento

- **Código & Scripts:** [Apache-2.0](./LICENSE)
- **Marca e Logotipo:** [CC-BY-ND-4.0](./LICENSE-LOGO)
- **Mídias e Ilustrações:** [CC-BY-SA-4.0](./LICENSE-MEDIA)
