#!/bin/bash
DATA=$(date +%d-%m-%y_%H%M%S)
echo dataatual: $DATA
horaatual=`date | awk '{print $4}'`
echo Hora: $horaatual
NUMAGENTES=$(cat -n /home/danieldiogenes/agentes.txt | tail -n 1 |awk -F " " '{print $1}') #Qtdade de agentes

for ((a=1 ; a<="$NUMAGENTES" ; a++))
do
AGENTE=$(head -n $a /home/danieldiogenes/agentes.txt |tail -n 1 |cut -d ";" -f 1 | tr ' ' '_')   #TRAZ O AGENTE
MOMENTOPAUSA=$(/usr/sbin/asterisk -rx "database show" | grep $AGENTE | grep /PAUSE | cut -d "-" -f 4 | tail -n 1 | tr ' ' '_')
echo $MOMENTOPAUSA
FILA=$(/usr/sbin/asterisk -rx "database show" | grep $AGENTE | grep /PAUSE | cut -d "/" -f 7 | tail -n 1 | tr ' ' '_')
NOME=$(grep "$AGENTE" /home/danieldiogenes/agentes.txt | cut -d ";" -f 2 | tr ' ' '_')
TIPODEPAUSA=$(/usr/sbin/asterisk -rx "database show" | grep $AGENTE | grep /PAUSE | cut -d ":" -f 2 | tail -n 1 | cut -d "/" -f 3 | tr ' ' '_')

if test -n "$MOMENTOPAUSA";

then

var11=$(echo "$MOMENTOPAUSA"  | cut -c 1-2)
var12=$(echo "$MOMENTOPAUSA" | cut -c 4-5)
var13=$(echo "$MOMENTOPAUSA" | cut -c 7-8)

var21=$(echo "$horaatual" | cut -c 1-2)
var22=$(echo "$horaatual" | cut -c 4-5)
var23=$(echo "$horaatual" | cut -c 7-8)

calc1=$(echo "$var11*3600 + $var12*60 + $var13" | bc)
calc2=$(echo "$var21*3600 + $var22*60 + $var23" | bc)

seg=$(echo "$calc2 - $calc1" | bc)


min=$(echo "$seg/60" | bc)
seg=$(echo "$seg-$min*60" | bc)
hor=$(echo "$min/60" | bc)

min1=$(echo "$min-$hor*60" | bc)
echo $min1

echo min: "$min"

echo $AGENTE

if [ "$min" -ge 15 ]; then

if [[ "$TIPODEPAUSA" = ?(+|-)+([0-9]) ]] ; then 

TIPODEPAUSA=$(grep "\b$TIPODEPAUSA\b" /home/danieldiogenes/tiposdepausa.txt | cut -d ";" -f 2 | tr ' ' '_')

else
echo "segue"
fi

#if [[ "$TIPODEPAUSA" != "Almoço" ]] ; then
if [[ "$TIPODEPAUSA" != "QUALQUER" && "$TIPODEPAUSA" != "Redes_Sociais" && "$TIPODEPAUSA" != "e-mail" && "$TIPODEPAUSA" != "Reclame_Aqui" && "$TIPODEPAUSA" != "Cupom_SAC" ]] ; then

if [ "$FILA" = FILA_1 ]; then

#TEXTO=`echo -e "Colaborador a mais de 15 minutos em pausa. \n Nome: "$NOME" \n Número do Agente: "$AGENTE" \n Tempo em pausa(hora/min/seg): "$hor:$min1:$seg" \n Pausa: "$TIPODEPAUSA" \n Fila: "$FILA""`
echo "${TEXTO}"
curl -X POST -H 'Content-Type: application/json' -d '{"chat_id": "-567874117", "text": "Colaborador a mais de 15 minutos em pausa!\nNome:'$NOME'\nCódigo de Agente:'$AGENTE'\nTempo em pausa:'$hor':'$min1':'$seg'\nPausa:'$TIPODEPAUSA'\nFila:'$FILA'", "disable_notification": false}'  https://api.telegram.org/bot1655885367:AAEYs2vr4kXH5D3bX-KOoUx-A5u0-cfCWKQ/sendMessage
#curl -X POST -H 'Content-Type: application/json' -d '{"chat_id": "1046796221", "text": "'$TEXTO'", "disable_notification": false}'  https://api.telegram.org/bot1655885367:AAEYs2vr4kXH5D3bX-KOoUx-A5u0-cfCWKQ/sendMessage

else

#TEXTO=`echo -e "Colaborador a mais de 10 minutos em pausa. \n Nome: "$NOME" \n Número do Agente: "$AGENTE" \n Tempo em pausa(hora/min/seg): "$hor:$min1:$seg" \n Pausa: "$TIPODEPAUSA" \n Fila: "$FILA""`
echo "${TEXTO}"
curl -X POST -H 'Content-Type: application/json' -d '{"chat_id": "-567874117", "text": "Colaborador a mais de 15 minutos em pausa!\nNome:'$NOME'\nCódigo de Agente:'$AGENTE'\nTempo em pausa:'$hor':'$min1':'$seg'\nPausa:'$TIPODEPAUSA'\nFila:'$FILA'", "disable_notification": false}'  https://api.telegram.org/bot1655885367:AAEYs2vr4kXH5D3bX-KOoUx-A5u0-cfCWKQ/sendMessage
#curl -X POST -H 'Content-Type: application/json' -d '{"chat_id": "1046796221", "text": "Nome:'$NOME'\nCódigo_de_Agente:'$AGENTE'\nTempo_em_pausa:'$hor':'$min1':'$seg'\nPausa:'$TIPODEPAUSA'\nFila:'$FILA'","disable_notification": false}'  https://api.telegram.org/bot1655885367:AAEYs2vr4kXH5D3bX-KOoUx-A5u0-cfCWKQ/sendMessage
fi

echo "vazio"

fi

else
echo "menor q 10min"

fi
else

echo "exceção de pausa"

fi
done
exit 0
