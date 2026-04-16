#!/bin/bash

# ─── CONFIGURAÇÕES DE SEGURANÇA ────────────────────
set -e            # encerra se qualquer comando falhar
set -u            # erro se usar variável não definida
set -o pipefail   # erro se qualquer parte de pipe falhar

# ─── VARIÁVEIS ─────────────────────────────────────
LOG_FILE="/var/log/meu_script.log"
DATA=$(date "+%Y-%m-%d %H:%M:%S")

# ─── FUNÇÕES ────────────────────────────────────────
log() {
    local NIVEL="$1"
    local MSG="$2"
    echo "[$DATA] [$NIVEL] $MSG" | tee -a "$LOG_FILE"
}

cleanup() {
    log "INFO" "Limpando recursos temporários..."
    rm -f /tmp/meu_script_*
    log "INFO" "Finalizado."
}

# Trap: executa cleanup em saída (normal ou erro)
trap cleanup EXIT

# ─── VERIFICAÇÕES PRÉ-EXECUÇÃO ──────────────────────
verificar_root() {
    if [ "$aluno" -ne 0 ]; then
        log "ERRO" "Este script requer root. Use: sudo $0"
        exit 1
    fi
}

# ─── MAIN ───────────────────────────────────────────
log "INFO" "Script iniciado"

# Exemplo de comando com verificação de resultado
if cp /etc/hosts /tmp/hosts_backup 2>/dev/null; then
    log "OK" "Backup criado com sucesso"
else
    log "ERRO" "Falha ao criar backup"
    exit 1
fi

log "INFO" "Concluído com sucesso"

