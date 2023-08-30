#!/bin/bash

# Número de telefone que você deseja consultar a operadora
numero_telefone="85991009681"

# URL do site para fazer a consulta web scraping
url="https://www.qualoperadora.net/consulta?tel=${numero_telefone}"

# Fazer a solicitação HTTP usando curl e salvar a resposta em uma variável
resposta=$(curl -s "$url")

# Extrair a informação da operadora usando grep
operadora=$(echo "$resposta" | grep -o '<strong>Operadora: </strong>[^<]*' | sed 's/<strong>Operadora: <\/strong>//')

# Exibir a informação da operadora
echo "Operadora do número $numero_telefone: $operadora"
