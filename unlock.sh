#!/bin/bash
echo "Unlock 1.0, Lembrando esse script funciona somente na versão RP1200"

# colocar o IP do seu equipamento
HOST='xxx.xxx.xxx.xxx' #olt cabedelo, por enquanto, depois mudar pra uma de bancada
USER='GEPON'
PASSWD='GEPON'
# nesse caso eu uso a mesma senha para o acesso e para o modo enable.

#Conectando na OLT e coletando todas as placas do equipamento

(echo open "$HOST"; sleep 1
echo "$USER"; sleep 0,5
echo "$PASSWD"; sleep 0,5
echo "terminal length 0"
echo "en"; sleep 0,5
echo "$PASSWD";sleep 0,5;
echo "showcard"; sleep 0,5
) | telnet | tee > placas_temp

echo "Vendo quais placas para executar os comandos..."

# Primeiro eu separo as linhas do retorno acima que tem a placa GCOB
# depois eu filtro novamente aqueles em que a placa se encontra ativa, pois o registro GCOB pode estar 
# em um slot onde a placa foi configurada mas foi removida

cat placas_temp | grep "GCOB" >> slots_temp
rm -rf placas_temp
cat slots_temp | grep "YES" | awk '{print $1}' >> placas_temp

echo "pronto... vou rodar os comandos.. 1 instante"

# Percorre o arquivo final das operações acima, executando os comandos de desbloqueio
while read -r slot;
do
(echo open "$HOST"; sleep 1
echo "$USER"; sleep 0,5
echo "$PASSWD"; sleep 0,5
echo "terminal length 0"
echo "en"; sleep 0,5
echo "$PASSWD";sleep 0,5
echo "cd service"; sleep 0,5
echo "telnet slot $slot"; sleep 0,5
echo "cd omci"; sleep 0,5
echo "set exception_detect para flag disable"; sleep 0,5
echo "cd .."; sleep 0,5
echo "debug"; sleep 0,5
echo "set policy param pon-interconnect-switch enable logicsn-auth-mode ctc"; sleep 0,5
echo "exit"; sleep 0,2
echo "quit"
) | telnet
done < placas_temp

# Remove os arquivos temporários criados durante o processo
echo "Limpando os arquivos temp"
sleep 1
rm -rf *temp
sleep 1
echo "Obrigado por usar"