#!/bin/bash
for url in $(cat lista_de_clientes | awk -F "|" {'print $1'})
do
  cliente=$(cat lista_de_clientes | grep $url | awk -F "|" {'print $2'})
    consulta_status=$(curl --connect-timeout 5 -s -o /dev/null -w "%{http_code}" "$url")
#echo $cliente: $consulta_status
  if [ "$consulta_status" = "200" ]; then
    echo "$cliente: A aplicação web OK. Status: $consulta_status"
    
  else
    echo "$cliente: A aplicação web está com problemas. Status: $consulta_status"
  fi
  done
exit 0

#Cds Extrafarma

#CD Hidrolandia.

#Nova VM CD's da Pmenos



