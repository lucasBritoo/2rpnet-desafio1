## DESAFIO 1: KUBERNETES E DOCKER

Desafio para testar conhecimentos sobre Docker + Kubernetes + Shell

## 🔨 Funcionalidades do projeto

- `Funcionalidade 1`: ✔️ Criar uma aplicação que fique exibindo o valor de uma variável de ambiente do sistema operacional de 20 em 20 segundos, o nome da variável deve ser "TWORPTEST" e o valor desta variável deve ser "true100%".
- `Funcionalidade 2`: ✔️ Criar um container usando docker ou outro orquestrador de containers similar.
- `Funcionalidade 3`: ✔️ fazer o upload da imagem construída para um container registry de preferência. Observação: o valor da variável deve ser exibido no log do container
- `Funcionalidade 4`: ✔️ Instanciar um cluster kubernetes local usando Minikube, K3D ou similar para criação e testes dos manifestos.
- `Funcionalidade 5`: ✔️ Criar manifestos kubernetes incluindo os tipos deployment e secret. O deployment deve rodar a imagem docker construida nas etapas anteriores e na secret deve ser adicionado a variável esperada pela aplicação e passada para o container como variável de ambiente.
- `Funcionalidade 6`: ✔️ Fazer um script bash que percorre os namespaces e coleta a secret de cada deployment para comparar se o valor da secret do deployment está sendo exibida no log do container que está rodando a aplicação. Se o valor da secret estiver sendo exibida retornar uma mensagem informando que o container tem um problema de segurança.

## ⚙ Ambiente de desenvolvimento

Este projeto foi desenvolvido utilizando uma máquina virtual instanciada em um servidor proxmox. O sistema operacional utilizado foi Ubuntu Server 22.04.1 LTS. Neste ambiente há configurado o Docker 20.10.21 (build baeda1f) e o Minikube v1.28.0. Foi utilizado o Docker Hub para registrar a imagem do container docker.

## 📁 Script em Python

O script 'main.py' desenvolvido em python imprime no stderr do container a variável de ambiente 'TWORPTEST' a cada 20 segundos configurados por um time.sleep(). A intenção de imprimir o valor da variável em stderr é exatamente imprimir este valor nos logs do container. 

Caso a variável de ambiente não exista no container é impresso: 'A variável de ambiente não foi encontrada'.

## 🐳 Container Docker 

O dockerfile deste projeto utiliza como imagem base 'python:3', é definido o diretório de trabalho em '/usr/src/app' e copiado o script 'main.py' para dentro do container. 

É necessário realizar o build do dockerfile e depois criar uma tag para a imagem gerada. Através dessa tag é possivel fazer o push para o DockerHub.

```
$ docker build -f dockerfile -t docker-kubernetes .
$ docker tag [IMAGE_ID] [USER_NAME]/docker-kubernetes:1.0

```
É necessário configurar o login do DockerHub através do usuário e senha. Após configurado, basta executar push para fazer upload da imagem.

```
$ docker login -u [USER_NAME] -p [PASSWORD]
$ docker push [USER_NAME]/docker-kubernetes:1.0
```

A imagem deste container já está registrada no meu DockerHub. Logo abaixo há o link de acesso:

Imagem DockerHub: https://hub.docker.com/repository/docker/lucasbrito0698/docker-kubernetes

### 🔒 Secrets

O manifesto para o secret 'secret.yaml' foi criado usando o nome 'secrets-desafio1'. Este secret contém a variável de ambiente 'TWORPTEST' com o valor 'true100%', esta variável é passada para os containers do cluster. Assim é possível imprimir seu resultado nos logs do container.

Para utilizar este secret é necessário encriptar usando base64.

```
$ echo -n  "true100%" | base64

Output: dHJ1ZTEwMCU=
```

Para criar a secret é necessário executar o seguinte comando:

```
$ kubectl apply -f secrets.yaml
```

## ☸️ Kubernetes

O manifesto para o deployment 'deployment.yaml' foi criado com 2 pods e com o namespace denominado 'desafio1-deployment'. Para que seja possível acessar a imagem no DockerHub é necessário adicionar um secrets com o login do DockerHub:

```
$ kubectl create secret docker-registry docker_login --docker-server=https://index.docker.io/v1/ --docker-username=[USER_NAME] --docker-password=[PASSWORD] --docker-email=[EMAIL]
```

Para criar os pods de deployment é necessário executar o seguinte comando:

```
$ kubectl apply -f deployment.yaml
```

Para exibir os logs dos containers presentes no cluste, basta digitar o comando abaixo. É possível ver que nos logs é exibido o valor da variável de ambiente 'TWORPTEST' com o valor 'true100%' decodificado. O valor é exibido a cada 20 segundos.

```
$ kubectl logs deployment/desafio1-deployment
```

## 🔀 Script em Shell

Foi criado um script em Shell que percorre os namespaces de deployments em busca de utilização dos pods que utilizam secrets. Quando encontrada uma secret é verificado se o seu valor decodificado é igual ao impresso nos logs dos containers presentes no cluster Kubernetes. 

Caso os valores sejam iguais, é impresso uma mnesagem no console: 'O container presente no namespace 'deployment/[NAME_DEPLOYMENT]' tem um problema de segurança'.

Se os valores foram distintos, é impresso a mensagem: 'Não encontramos nenhum problema de segurança'
