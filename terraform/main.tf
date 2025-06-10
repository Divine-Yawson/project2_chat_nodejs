provider "aws" {
  region = "us-east-1"
}

resource "aws_key_pair" "chat_key" {
  key_name   = "chat-app-key"
  public_key = file("~/.ssh/id_rsa.pub")
}

resource "aws_security_group" "chat_sg" {
  name        = "chat-sg"
  description = "Allow HTTP, HTTPS, and SSH"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["YOUR_IP/32"] # Change to your IP
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
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

data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

resource "aws_instance" "chat_server" {
  ami                    = data.aws_ami.amazon_linux.id
  instance_type          = "t2.micro"
  key_name               = aws_key_pair.chat_key.key_name
  vpc_security_group_ids = [aws_security_group.chat_sg.id]

  user_data = <<-EOF
              #!/bin/bash
              yum update -y
              amazon-linux-extras enable epel
              yum install -y git nginx nodejs npm
              systemctl start nginx
              systemctl enable nginx

              git clone https://github.com/YOUR_USERNAME/chat-app.git /home/ec2-user/chat-app
              cd /home/ec2-user/chat-app
              npm install

              cat <<EOL > /etc/systemd/system/chat-app.service
              [Unit]
              Description=Node.js Chat App
              After=network.target

              [Service]
              ExecStart=/usr/bin/node /home/ec2-user/chat-app/app.js
              Restart=always
              User=ec2-user
              Environment=PATH=/usr/bin:/usr/local/bin
              Environment=NODE_ENV=production

              [Install]
              WantedBy=multi-user.target
              EOL

              systemctl daemon-reexec
              systemctl daemon-reload
              systemctl start chat-app
              systemctl enable chat-app

              cat <<EOL > /etc/nginx/conf.d/chat.conf
              server {
                  listen 80;
                  server_name _;

                  location / {
                      proxy_pass http://localhost:3000;
                      proxy_http_version 1.1;
                      proxy_set_header Upgrade \$http_upgrade;
                      proxy_set_header Connection 'upgrade';
                      proxy_set_header Host \$host;
                      proxy_cache_bypass \$http_upgrade;
                  }
              }
              EOL

              systemctl restart nginx
              EOF

  tags = {
    Name = "NodeChatServer"
  }
}

resource "aws_eip" "chat_eip" {
  instance = aws_instance.chat_server.id
  vpc      = true
  depends_on = [aws_instance.chat_server]
}
