data "aws_ami" "amazon_linux_2023" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-2023.*-x86_64"]
  }
}

resource "aws_security_group" "linux_bastion" {
  name        = "${local.app1_name}-linux-bastion-sg"
  description = "Allow SSH access to Linux bastion"
  vpc_id      = aws_vpc.app1.id

  ingress {
    description = "SSH from allowed admin network"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.bastion_allowed_cidr]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${local.app1_name}-linux-bastion-sg"
  }
}

resource "aws_security_group" "linux_app1" {
  name        = "${local.app1_name}-linux-sg"
  description = "Allow SSH from App1 VPC"
  vpc_id      = aws_vpc.app1.id

  ingress {
    description = "All traffic from anywhere"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${local.app1_name}-linux-sg"
  }
}

resource "aws_security_group" "linux_app2" {
  name        = "${local.app2_name}-linux-sg"
  description = "Allow SSH from App1 VPC (bastion source)"
  vpc_id      = aws_vpc.app2.id

  ingress {
    description = "All traffic from anywhere"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${local.app2_name}-linux-sg"
  }
}

resource "aws_instance" "linux_bastion" {
  ami                         = data.aws_ami.amazon_linux_2023.id
  instance_type               = var.linux_instance_type
  subnet_id                   = aws_subnet.app1_public.id
  vpc_security_group_ids      = [aws_security_group.linux_bastion.id]
  key_name                    = aws_key_pair.lab.key_name
  associate_public_ip_address = true
  user_data                   = <<-EOT
    #!/bin/bash
    set -euo pipefail

    hostnamectl set-hostname "${local.app1_name}-linux-bastion"

    install -d -m 700 -o ec2-user -g ec2-user /home/ec2-user/.ssh

    cat > /home/ec2-user/.ssh/config <<EOF
    Host ${local.app1_name}-linux1 linux1
      HostName ${aws_instance.linux1.private_ip}
      User ec2-user
      StrictHostKeyChecking accept-new

    Host ${local.app2_name}-linux2 linux2
      HostName ${aws_instance.linux2.private_ip}
      User ec2-user
      StrictHostKeyChecking accept-new
    EOF

    chown ec2-user:ec2-user /home/ec2-user/.ssh/config
    chmod 600 /home/ec2-user/.ssh/config
  EOT

  tags = {
    Name = "${local.app1_name}-linux-bastion"
    Role = "bastion"
  }
}

resource "aws_instance" "linux1" {
  ami                    = data.aws_ami.amazon_linux_2023.id
  instance_type          = var.linux_instance_type
  subnet_id              = aws_subnet.app1_private.id
  vpc_security_group_ids = [aws_security_group.linux_app1.id]
  key_name               = aws_key_pair.lab.key_name
  user_data              = <<-EOT
    #!/bin/bash
    set -euo pipefail

    hostnamectl set-hostname "${local.app1_name}-linux1"
  EOT

  tags = {
    Name = "${local.app1_name}-linux1"
    Role = "workload"
  }
}

resource "aws_instance" "linux2" {
  ami                    = data.aws_ami.amazon_linux_2023.id
  instance_type          = var.linux_instance_type
  subnet_id              = aws_subnet.app2_private.id
  vpc_security_group_ids = [aws_security_group.linux_app2.id]
  key_name               = aws_key_pair.lab.key_name
  user_data              = <<-EOT
    #!/bin/bash
    set -euo pipefail

    hostnamectl set-hostname "${local.app2_name}-linux2"
  EOT

  tags = {
    Name = "${local.app2_name}-linux2"
    Role = "workload"
  }
}
