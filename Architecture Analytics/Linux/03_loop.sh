#!/bin/bash

echo "=== Loop FOR com lista ==="
for FRUTA in maçã banana laranja uva; do
    echo "  Fruta: $FRUTA"
done

echo ""
echo "=== Loop FOR com range ==="
for I in $(seq 1 5); do
    echo "  Contando: $I"
done

echo ""
echo "=== Loop WHILE ==="
CONTADOR=0
while [ $CONTADOR -lt 3 ]; do
    echo "  Contador: $CONTADOR"
    CONTADOR=$((CONTADOR + 1))
done

echo ""
echo "=== Loop em arquivos ==="
for ARQUIVO in *.sh; do
    echo "  Script encontrado: $ARQUIVO"
done

