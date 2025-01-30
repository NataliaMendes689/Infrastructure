# Projeto de Infraestrutura com Terraform, Ansible e Monitoramento

Este projeto provisiona uma instância EC2 na AWS, configura o servidor com Ansible e configura monitoramento com Prometheus e Grafana.

## Requisitos

- Terraform instalado
- Ansible instalado
- Docker instalado

## Como usar

1. Provisionamento com Terraform:
   - Entre na pasta terraform/.
   - Execute terraform init para inicializar o Terraform.
   - Execute terraform apply para criar a infraestrutura.

2. Configuração do servidor com Ansible:
   - Entre na pasta ansible/.
   - Execute ansible-playbook -i hosts playbook.yml.

3. Monitoramento com Prometheus e Grafana:
   - Entre na pasta monitoring/.
   - Execute docker-compose up -d para iniciar os contêineres.
   - Acesse o Grafana em http://<IP_DO_SERVIDOR>:3000. # Pegar no arquivo hosts

# Especificação

- main.tf: Arquivo principal do Terraform, onde estão os recursos a serem criados (instância EC2, Security Group, etc.).
- outputs.tf: Arquivo para definir as saídas do Terraform (por exemplo, o IP público da instância).
- variables.tf: Arquivo para definir variáveis usadas no Terraform.
- terraform.tfvars: Arquivo para atribuir valores às variáveis definidas em variables.tf.

- playbook.yml: Playbook do Ansible para instalar e configurar o servidor (por exemplo, Apache, MySQL, WordPress).
- hosts: Arquivo de inventário do Ansible, onde você define os IPs dos servidores a serem configurados.

- docker-compose.yml: Arquivo para configurar e iniciar os contêineres do Prometheus e Grafana.
- prometheus.yml: Arquivo de configuração do Prometheus.


# Como Executar o Projeto

## Provisionamento com Terraform:

1. Entre na pasta terraform/.

2. Execute terraform init e terraform apply.


## Configuração do servidor com Ansible (opcional):

1. Entre na pasta ansible/.

2. Execute ansible-playbook -i hosts playbook.yml.


## Monitoramento com Prometheus e Grafana:

1. Entre na pasta monitoring/.

2. Execute docker-compose up -d
