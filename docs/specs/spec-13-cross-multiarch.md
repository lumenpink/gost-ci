# Especificação Técnica — Sub-imagem Atômica `gost-ci-cross` Multi-Arquitetura (#13)

## 1. Contexto e Motivação
A distribuição multi-arquitetura na Banca (`https://banca.2lp.in/downloads/`) exige artefatos para:
- `linux-amd64` (`x86_64-unknown-linux-musl` e `x86_64-unknown-linux-gnu`)
- `linux-arm64` (`aarch64-unknown-linux-musl` e `aarch64-unknown-linux-gnu`)
- `windows-amd64` (`x86_64-pc-windows-gnu`)

Para garantir builds herméticos, determinísticos e rápidos nos executores de CI do Forgejo sem a necessidade de instalações manuais de pacotes a cada execução de esteira, a sub-imagem `codeberg.org/lumenpink/gost-ci-cross` deve prover todos os compiladores cruzados, linkers e alvos Rust pré-instalados.

## 2. Requisitos da Sub-Imagem (`images/cross/Dockerfile`)

### 2.1 Toolchains e Pacotes Nativos Debian (Bookworm)
- **Linux ARM64:** `gcc-aarch64-linux-gnu`, `libc6-dev-arm64-cross`
- **Linux 32-bit (legado preservado):** `gcc-i686-linux-gnu`, `libc6-dev-i386-cross`, `gcc-arm-linux-gnueabihf`, `libc6-dev-armhf-cross`
- **Linux Estático:** `musl-tools`
- **Windows x86_64:** `gcc-mingw-w64-x86-64`, `mingw-w64-tools`, `zip`
- **Cross-compilação moderna:** `python3-pip`, `cargo-zigbuild`, `ziglang`

### 2.2 Alvos Rustup Pré-instalados
- `x86_64-unknown-linux-gnu`
- `x86_64-unknown-linux-musl`
- `aarch64-unknown-linux-gnu`
- `aarch64-unknown-linux-musl`
- `x86_64-pc-windows-gnu`
- `i686-unknown-linux-gnu`
- `armv7-unknown-linux-gnueabihf`

### 2.3 Variáveis de Ambiente do Cargo Linker
- `CARGO_TARGET_AARCH64_UNKNOWN_LINUX_GNU_LINKER=aarch64-linux-gnu-gcc`
- `CARGO_TARGET_AARCH64_UNKNOWN_LINUX_MUSL_LINKER=aarch64-linux-gnu-gcc`
- `CARGO_TARGET_X86_64_PC_WINDOWS_GNU_LINKER=x86_64-w64-mingw32-gcc`
- `CARGO_TARGET_X86_64_UNKNOWN_LINUX_MUSL_LINKER=musl-gcc`

## 3. Critérios de Aceite
1. Validação estrita via script de teste automatizado `tests/test-cross-multiarch.sh`.
2. O Dockerfile compila declarativamente todos os pacotes e alvos exigidos.
3. Documentação no `README.md` refletindo os alvos multi-arquitetura disponíveis.
4. Aprovação integral na auditoria GOST `cccp check --strict`.
