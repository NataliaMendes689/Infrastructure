resource "aws_security_group" "web" {
  name_prefix = "${var.project_name}-web-"
  description = "HTTP/HTTPS from the internet, SSH from named CIDRs only"

  # name_prefix plus this lifecycle lets the group be replaced without first
  # detaching the instance, which a fixed name would deadlock on.
  lifecycle {
    create_before_destroy = true
  }

  tags = {
    Name = "${var.project_name}-web"
  }
}

resource "aws_vpc_security_group_ingress_rule" "http" {
  for_each = toset(var.http_allowed_cidrs)

  security_group_id = aws_security_group.web.id
  description       = "HTTP"
  cidr_ipv4         = each.value
  from_port         = 80
  to_port           = 80
  ip_protocol       = "tcp"
}

resource "aws_vpc_security_group_ingress_rule" "https" {
  for_each = toset(var.http_allowed_cidrs)

  security_group_id = aws_security_group.web.id
  description       = "HTTPS"
  cidr_ipv4         = each.value
  from_port         = 443
  to_port           = 443
  ip_protocol       = "tcp"
}

# Restricted by a variable validation that rejects 0.0.0.0/0.
resource "aws_vpc_security_group_ingress_rule" "ssh" {
  for_each = toset(var.ssh_allowed_cidrs)

  security_group_id = aws_security_group.web.id
  description       = "SSH for configuration management"
  cidr_ipv4         = each.value
  from_port         = 22
  to_port           = 22
  ip_protocol       = "tcp"
}

resource "aws_vpc_security_group_egress_rule" "all" {
  security_group_id = aws_security_group.web.id
  description       = "Package downloads and updates"
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}
