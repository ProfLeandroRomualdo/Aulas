#!/bin/bash

# $1 é o primeiro argumento passado ao script
NUMERO=$1

# Verificar se o argumento foi fornecido
if [ -z "$NUMERO" ]; then
    echo "Uso: $0 <numero>"
    exit 1
fi

# Comparação numérica
if [ "$NUMERO" -gt 100 ]; then
    echo "$NUMERO é GRANDE (maior que 100)"
elif [ "$NUMERO" -gt 10 ]; then
    echo "$NUMERO é MÉDIO (entre 11 e 100)"
else
    echo "$NUMERO é PEQUENO (10 ou menos)"
fi

