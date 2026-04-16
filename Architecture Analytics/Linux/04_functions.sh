#!/bin/bash

# ─── FUNÇÕES ───────────────────────────────────────

# Função para mostrar cabeçalho
mostrar_cabecalho() {
    echo "================================"
    echo "  $1"
    echo "================================"
}

# Função que verifica se arquivo existe
verificar_arquivo() {
    local ARQUIVO="$1"   # local = variável só existe dentro da função
    if [ -f "$ARQUIVO" ]; then
        echo "✓ Arquivo existe: $ARQUIVO"
        return 0   # sucesso
    else
        echo "✗ Arquivo NÃO encontrado: $ARQUIVO"
        return 1   # erro
    fi
}

# ─── PROGRAMA PRINCIPAL ────────────────────────────

mostrar_cabecalho "Verificador de Arquivos"

ARQUIVOS=("/etc/hosts" "/etc/shadow" "/tmp/teste.txt")

for ARQ in "${ARQUIVOS[@]}"; do
    verificar_arquivo "$ARQ"
done

