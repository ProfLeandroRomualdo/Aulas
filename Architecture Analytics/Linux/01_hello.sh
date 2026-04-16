#!/bin/bash
# Comentários começam com #
# Este script é uma introdução ao Bash

# Variáveis: sem espaços ao redor do =
NOME="Linux"
VERSAO=1

# echo imprime na tela
echo "Olá, $NOME!"
echo "Este é o script número $VERSAO"

# date: data/hora atual
echo "Executado em: $(date)"

# Variáveis especiais do sistema
echo "Usuário atual: $USER"
echo "Diretório home: $HOME"
echo "Diretório atual: $PWD"

