# Especificação Técnica: Suporte a gmp e zip na Imagem gost-ci-php

**Ticket Associado:** #30  
**Branch:** `fix/30-php-gmp-android-dx`  
**Norma:** GOST 1.4.0

## 1. Objetivo
Prover o utilitário CLI `zip` e a extensão PHP `gmp` na imagem `gost-ci-php` para garantir execução verde das esteiras de testes do ecossistema (notadamente `indieinabox` para Nostr BIP-340 e ThemeManager ZIP).

## 2. Requisitos Técnicos
1. **`images/php/Dockerfile`:**
   - Adicionar `zip` ao pacote `apt-get install`.
   - Adicionar `gmp` à lista de `install-php-extensions`.

## 3. Critérios de Aceitação
- Build hermético e sintaxe válida no Dockerfile do PHP.
