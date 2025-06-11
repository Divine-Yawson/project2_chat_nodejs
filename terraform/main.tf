provider "aws" {
  region = "us-east-1" # change to your region if needed
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

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# Get the default VPC
data "aws_vpc" "default" {
  default = true
}

# Get all default subnets in that VPC
data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }

  filter {
    name   = "default-for-az"
    values = ["true"]
  }
}

# Select the first default subnet
locals {
  selected_subnet_id = data.aws_subnets.default.ids[0]
}

# Security Group allowing HTTP, HTTPS, SSH
resource "aws_security_group" "chat_sg" {
  name        = "chat-sg"
  description = "Allow HTTP, HTTPS and SSH"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

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

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# EC2 instance
resource "aws_instance" "chat_server" {
  ami                         = data.aws_ami.amazon_linux.id
  instance_type               = "t3.micro"
  key_name                    = "tonykey"
  subnet_id                   = local.selected_subnet_id
  vpc_security_group_ids      = [aws_security_group.chat_sg.id]
  associate_public_ip_address = true

  tags = {
    Name = "NodeChatApp"
  }
}

# Allocate and associate an Elastic IP
resource "aws_eip" "chat_eip" {
  instance = aws_instance.chat_server.id
}
