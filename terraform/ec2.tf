data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-2023*-x86_64"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

resource "aws_instance" "app" {
  ami                         = data.aws_ami.amazon_linux.id
  instance_type               = var.app_instance_type
  subnet_id                   = aws_subnet.public[0].id
  vpc_security_group_ids      = [aws_security_group.app.id]
  associate_public_ip_address = true

  iam_instance_profile = aws_iam_instance_profile.ec2.name

  user_data = <<-EOF_USERDATA
    #!/bin/bash
    set -eux

    dnf update -y
    dnf install -y docker

    systemctl enable docker
    systemctl start docker

    usermod -aG docker ec2-user

    # Install Docker Compose plugin
    mkdir -p /usr/local/lib/docker/cli-plugins

    curl -SL \
      https://github.com/docker/compose/releases/download/v2.39.2/docker-compose-linux-x86_64 \
      -o /usr/local/lib/docker/cli-plugins/docker-compose

    chmod +x /usr/local/lib/docker/cli-plugins/docker-compose

    # Ensure SSM Agent is running
    systemctl enable amazon-ssm-agent
    systemctl start amazon-ssm-agent
  EOF_USERDATA

  root_block_device {
    volume_size = 20
    volume_type = "gp3"
    encrypted   = true
  }

  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 2
  }

  tags = {
    Name        = "${var.project_name}-app"
    Project     = var.project_name
    Role        = "application"
    Environment = "staging"
  }
}

resource "aws_instance" "monitoring" {
  ami                         = data.aws_ami.amazon_linux.id
  instance_type               = var.monitoring_instance_type
  subnet_id                   = aws_subnet.public[1].id
  vpc_security_group_ids      = [aws_security_group.monitoring.id]
  associate_public_ip_address = true

  iam_instance_profile = aws_iam_instance_profile.ec2.name

  user_data = <<-EOF_USERDATA
    #!/bin/bash
    set -eux

    dnf update -y
    dnf install -y docker

    systemctl enable docker
    systemctl start docker

    usermod -aG docker ec2-user

    # Install Docker Compose plugin
    mkdir -p /usr/local/lib/docker/cli-plugins

    curl -SL \
      https://github.com/docker/compose/releases/download/v2.39.2/docker-compose-linux-x86_64 \
      -o /usr/local/lib/docker/cli-plugins/docker-compose

    chmod +x /usr/local/lib/docker/cli-plugins/docker-compose

    # Ensure SSM Agent is running
    systemctl enable amazon-ssm-agent
    systemctl start amazon-ssm-agent
  EOF_USERDATA

  root_block_device {
    volume_size = 20
    volume_type = "gp3"
    encrypted   = true
  }

  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 2
  }

  tags = {
    Name        = "${var.project_name}-monitoring"
    Project     = var.project_name
    Role        = "monitoring"
    Environment = "staging"
  }
}
