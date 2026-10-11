# WordPress on AWS — Terraform, Ansible and monitoring

Provisioning, configuration and observability for a single-instance WordPress server.

| Folder | Responsibility |
| --- | --- |
| `terraform/` | EC2 instance, security group, encrypted root volume, IMDSv2 |
| `ansible/` | Apache, MySQL, PHP, WordPress, virtual host, `wp-config.php` |
| `monitoring/` | Prometheus, node-exporter and Grafana over Compose |

Run instructions and the reasoning behind each design choice are in the
[repository README](../../README.md).

## Layout

```
terraform/
  versions.tf                required_version and provider constraints
  variables.tf               inputs, with validation
  main.tf                    provider, AMI lookup, instance
  security.tf                security group and its rules
  outputs.tf                 IP, DNS, AMI id, ready-made Ansible inventory
  terraform.tfvars.example   copy to terraform.tfvars, which is gitignored

ansible/
  playbook.yml               the full install, idempotent
  wp-config.php.j2           templated config with salts fetched at run time
  requirements.yml           community.mysql and community.general
  inventory.ini.example      copy to inventory.ini, which is gitignored

monitoring/
  docker-compose.yml         prometheus, node-exporter, grafana
  prometheus.yml             scrape config
  grafana/provisioning/      datasource wired up on first boot
  .env.example               copy to .env, which is gitignored
```

## Known limits

Single instance, no load balancer, no managed database, no TLS termination. State is
local, so this is a single-operator lab rather than a team setup — an S3 backend with
DynamoDB locking is the first thing to add before anyone else touches it.
