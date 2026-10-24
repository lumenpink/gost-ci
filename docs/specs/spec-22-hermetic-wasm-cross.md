# Especificação Técnica — Hermeticidade e Execução Offline em gost-ci-wasm (#22)

## 1. Contexto e Motivação
No modelo operacional do ecossistema GOST, as compilações em contêineres de CI devem garantir reprodutibilidade hermética e capacidade estrita de execução offline (`--network none`).

Identificou-se que a imagem `gost-ci-wasm`, ao executar comandos de compilação da CLI do Dioxus (`dx build -p lauda-client --platform web --release`), disparava requisições externas não determinísticas para download de ferramentas auxiliares em tempo de execução:
1. `wasm-bindgen-cli` (versão específica 0.2.129).
2. `wasm-opt` (otimizador de bytecode WebAssembly do projeto Binaryen).
3. `esbuild` (bundler JavaScript/CSS nativo).

Em runners isolados ou com restrições de rede externa, essas tentativas de download falham, quebrando as esteiras de compilação web do ecossistema.

---

## 2. Requisitos Mandatórios

### 2.1 Fixação Hermética de Binários em images/wasm/Dockerfile
A imagem `gost-ci-wasm` DEVE conter previamente pré-instalados em suas camadas de build:

1. **`wasm-bindgen-cli` 0.2.129:**
   - Binário fixado na versão `0.2.129`.
   - Disponível no `PATH` do sistema (`/usr/local/bin/wasm-bindgen` e link simbólico em `/root/.cargo/bin/wasm-bindgen`).
2. **`wasm-opt` (Binaryen):**
   - Binário do utilitário `wasm-opt` pré-instalado em `/usr/local/bin/wasm-opt`.
   - Permissão de execução configurada para todos os usuários.
3. **`esbuild`:**
   - Binário nativo x86_64 instalado globalmente e disponível no `PATH` (`/usr/local/bin/esbuild`).

### 2.2 Proibição de Downloads em Runtime
Nenhum build web executado dentro de `gost-ci-wasm` pode tentar efetuar downloads adicionais de `wasm-bindgen`, `wasm-opt` ou `esbuild`. A CLI `dx` detectará as ferramentas nativas já existentes no `PATH` e operará de forma determinística e 100% offline.

---

## 3. Critérios de Aceite e Qualidade (DD-TDD)
1. **Fase 4 (Red Test):** O script `tests/test-hermetic-wasm.sh` deve auditar `images/wasm/Dockerfile` e falhar caso qualquer um dos três utilitários (`wasm-bindgen-cli` 0.2.129, `wasm-opt` e `esbuild`) esteja ausente.
2. **Fase 5 (Green Implement):** Dockerfile atualizado; testes devem passar com sucesso.
3. **Fase 7 (Mutation Test):** Teste de mutação deve comprovar que a remoção de qualquer uma das ferramentas gera falha de auditoria.
