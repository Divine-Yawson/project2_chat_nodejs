provider "aws" {
  region = "us-east-1" # Change if needed
}

# Get the latest Amazon Linux 2023 AMI
data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
}

# Get the default VPC
data "aws_vpc" "default" {
  default = true
}

# Get the default subnet (first one found)
data "aws_subnet" "default" {
  filter {
    name   = "default-for-az"
    values = ["true"]
  }

  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }

  availability_zone = "us-east-1a" # Adjust if needed
}

# Security Group
resource "aws_security_group" "chat_app_sg" {
  name        = "chat-app-sg"
  description = "Allow HTTP, HTTPS, and SSH"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow all outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# EC2 instance
resource "aws_instance" "chat_app" {
  ami                    = data.aws_ami.amazon_linux.id
  instance_type          = "t3.medium"
  subnet_id              = data.aws_subnet.default.id
  vpc_security_group_ids = [aws_security_group.chat_app_sg.id]
  key_name               = "tonykey"

  user_data = <<-EOF
              #!/bin/bash
              dnf update -y
              dnf install -y python3 pip git
              pip3 install --upgrade pip
              pip3 install ansible
              EOF

  root_block_device {
    volume_size = 16
    volume_type = "gp2"
  }

  tags = {
    Name = "chat-app-instance"
  }
}

# Elastic IP (optional)
resource "aws_eip" "chat_app_eip" {
  instance = aws_instance.chat_app.id
}
