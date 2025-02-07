# Ciclo DevOps - Elvenworks SRE

## PRIMEIRA SEMANA:

Desafio 0 - Fazer o fork do repositório em um repositório privado seu

Desafio 1 - Rodar essa aplicação na sua maquina

Desafio 2 - Dockernizar essa aplicação e provisionar

Desafio 3 - Provisionar a app  usando o terraform local na maquina (https://developer.hashicorp.com/terraform/tutorials/docker-get-started) com docker

Desafio 4 - Usando o kind (https://kind.sigs.k8s.io/) ou outro semelhante, provisione a mesma aplicação - service - deployment - ingress (completo)

Desafio 5 - Monitorar o cluster local com prometheus + grafana (instalação via Helm) + dashboard + alerta no 1P

## SEGUNDA SEMANA:

Desafio 6 - Provisionar os recursos VPC (2 zonas de disponibilidade), EKS (3 nodes groups - 2 spot e 1 on-demand), Kafka, Redis, Opensearch e RDS com o terraform.

Desafio 7 - Fazer o deploy da aplicação utilizando o Argo CD (esta pipiline deve utilizar o github actions para fazer a etapa do build e o repositorio de imagens deve ser o docker)

Desafio 8 - Coletar metricas de APM e Recursos

Desafio 9 - Coletar logs do cluster e aplicação e enviar para o opensearch

Desafio 10 - Deixar todos os arquivos values, configs e etc (infra, app e etc) organizado dentro de um repositorio de manteira organizada e documentada (infra-as-code)

Desafio 11 - Uma documentação completa de tudo que foi feito, as dificuldades e o aprendizados durante o desafio

*** Obs.: Garantir que tudo siga os padroes de qualidade, disponibilidade e segurança ***
