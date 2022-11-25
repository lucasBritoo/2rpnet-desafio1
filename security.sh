#!/bin/bash


QNT_NAMESPACE=`kubectl get deployment | wc -l`          #retorna a quantidade de linhas em namespace
declare -a LIST_NAMESPACE                               #vetor para armazenar os namespace deployment

cont=1                                                  #contador de namespace
echo "-> ENCONTRANDO NAMESPACES DEPLOYMENTS"
#lopp para percorrer os resultados de namespaces
for index in $(seq 2 $QNT_NAMESPACE); do

    aux=`kubectl get deployment | sed -n "$index p" `   #aux recebe os nomes dos namespaces 
    aux=`echo $aux | cut -d' ' -f 1`                    #aux é tratado para ter somente o nome, sem outras colunas de informacoes

    LIST_NAMESPACE[$cont]="$aux"                        #armazena no vetor de namespace
    cont=$((cont + 1))                                  #incrementa contador de namespace
    
done

echo "-> PERCORRENDO LISTA DE NAMESPACE ENCONTRADOS"
#loop para percorrer o vetor de namespace
for index in $(seq 1 $((cont - 1))); do 

    echo "   NAMESPACE: deployment/${LIST_NAMESPACE[$index]}"

    qnt_lines_describe=`kubectl describe deployment/${LIST_NAMESPACE[$index]} | wc -l`          #retorna quantidade de linhas do arquivo describe deployment
    
    #loop para percorrer o arquivo describe em busca do nome das secrets utilizadas no namespace deployment
    for aux_index in $(seq 1 $qnt_lines_describe); do

        aux=`kubectl describe deployment/${LIST_NAMESPACE[$index]} | sed -n "$aux_index p" `    #retorna linha por linha do describe
        aux=`echo "$aux" | grep "in secret" `                                                   #retorna a linha atual caso ela tenha in secret em seu texto

        #caso a linha atual tenha in secret no texto
        if ! [ "$aux" = "" ];then
 
            aux=`echo $aux | sed "s/.*in secret '//"`                                           #aux é tratado filtrando uma substring in secret
            aux=`echo $aux | sed "s/'.*//"`                                                     #aux é tratado filtrando todo o resto da linha, exceto o nome da secret utilziada no namespace
            break
        fi

    done

    echo "   SECRET: $aux"

    aux_secret=`kubectl get secret "$aux" -o jsonpath='{.data}'`                                #retorna o valor da secret encontrada
    aux_secret=`echo $aux_secret | sed 's/.*:"//'`                                              #aux_secret é tratado filtrando uma substring :
    aux_secret=`echo $aux_secret | sed 's/".*//'`                                               #aux_secret é tratado filtrano todo o resto da linha, exceto o valor da secret
  
    echo "   VALOR SECRET BASE64: "$aux_secret""
    secret_kubernetes="$aux_secret"                                                             
    secret_kubernetes=`echo "$secret_kubernetes" | base64 --decode`                             #converte o valor da secrete na base64


    echo "   VALOR SECRET: "$secret_kubernetes""
    secret_container=`kubectl logs "deployment/${LIST_NAMESPACE[$index]}" | tail -n1`           #retorna os logs dos containers do namespace encontrado
    secret_container=`echo "$secret_container" | grep "$secret_kubernetes" `                    #retorna uma substring caso encontre o valor da secret no log do container

    echo "   VALOR SECRET CONTAINER: "$secret_container""
    #condicao para verificar se o valor da secret esta presente no log do container
    if ! [ "$secret_container" = "" ]; then
        echo ""
        echo "-> O container presente no namespace 'deployment/${LIST_NAMESPACE[$index]}' tem um problema de seguranca"
        echo ""
    else
        echo ""
        echo "Nao encontramos nenhum problema de seguranca"
        echo ""
    fi
    
    
done