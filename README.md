# Infrastructure

Infrastructure-as-code studies: provisioning, configuration management and monitoring
on AWS, with Terraform, Ansible and Docker.

[![ci](https://github.com/NataliaMendes689/Infrastructure/actions/workflows/ci.yml/badge.svg)](https://github.com/NataliaMendes689/Infrastructure/actions/workflows/ci.yml)
![Terraform](https://img.shields.io/badge/Terraform-7B42BC?style=flat-square&logo=terraform&logoColor=white)
![Ansible](https://img.shields.io/badge/Ansible-EE0000?style=flat-square&logo=ansible&logoColor=white)
![Docker](https://img.shields.io/badge/Docker-2496ED?style=flat-square&logo=docker&logoColor=white)

## Projects

### `DevOps/Projeto-Wordpress-Terraform-Ansible`

A full provisioning chain: Terraform builds the EC2 instance and its security group,
Ansible installs and configures the WordPress stack on it, and a Compose stack
collects host metrics into Prometheus and Grafana.

```
terraform apply  →  EC2 + security group  →  ansible-playbook  →  Apache + MySQL + WordPress
                                                               →  docker compose up  →  metrics
```

### `DevOps/Projeto-Wordpress-Básico-Pipeline/terraform/s3-bucket-static`

A static site bucket: website configuration, a public-read bucket policy, versioning,
server-side encryption, and a separate access-log bucket with a 90-day lifecycle.

## Running it

### Terraform

```bash
cd DevOps/Projeto-Wordpress-Terraform-Ansible/terraform
cp terraform.tfvars.example terraform.tfvars   # fill in key_name and your own CIDR
terraform init
terraform plan
terraform apply
```

`terraform output ansible_inventory` prints the inventory block for the next step.

### Ansible

```bash
cd ../ansible
ansible-galaxy collection install -r requirements.yml
cp inventory.ini.example inventory.ini         # paste the address from Terraform
ansible-playbook -i inventory.ini playbook.yml --ask-vault-pass
```

The database password is required and never defaulted. Supply it with
`ansible-vault` or `-e wordpress_db_password=...`; the playbook refuses to run
without one of at least 12 characters.

### Monitoring

```bash
cd ../monitoring
cp .env.example .env                           # set a real Grafana password
docker compose up -d
```

Grafana on `:3000` with the Prometheus datasource already provisioned.

## Design notes

**SSH is never open to the world.** `ssh_allowed_cidrs` has a validation block that
rejects `0.0.0.0/0` outright, so the stack fails at plan time rather than exposing
port 22. HTTP and HTTPS stay public, which is the point of a web server.

**The AMI is resolved, not pinned.** A hardcoded AMI id is region-specific and stops
receiving security patches the day it is written. A `data "aws_ami"` lookup filtered
to Canonical's Ubuntu 24.04 images gets the current one at plan time.

**IMDSv2 is required.** Without it, a server-side request forgery in the web
application can read instance role credentials straight off the metadata endpoint.

**The playbook is idempotent.** The archive extraction is guarded by `creates:`,
Apache restarts through a handler rather than on every run, and `a2ensite` is guarded
by `creates:`. Running it twice changes nothing the second time.

**Secrets are not in the repository.** `terraform.tfvars`, `inventory.ini` and `.env`
are gitignored; each has a committed `.example` showing the shape without the values.

**Why the static bucket has no HTTPS-only policy.** The S3 website endpoint only
speaks HTTP, so an `aws:SecureTransport` deny would make the site unreachable rather
than secure. TLS means fronting the bucket with CloudFront and an Origin Access
Control, with the bucket made private — a deliberate next step, not an oversight.

## Checked in CI

`terraform fmt -check`, `terraform validate`, `ansible-lint`, `yamllint` and
`docker compose config` run on every push.
