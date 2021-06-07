provider "aws" {
  region = var.region
}

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
  owners = ["099720109477"] # Canonical
}

resource "aws_security_group" "ssh_access" {
  name = "ssh_access"

  # SSH access from the VPC
  ingress {
    from_port   = 22
    to_port     = 22
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

resource "aws_instance" "node" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = "t2.micro"
  vpc_security_group_ids = [aws_security_group.ssh_access.id]

  user_data = templatefile("../scripts/user_data.tmpl",
    { node_name             = var.node_name,
      environment           = var.environment,
      chef_server_url       = var.chef_server_url
      validator_name        = var.validator_name,
      validator_private_key = var.validator_private_key
  })

  #  key_name   = "ssh-key-pair-name"

  tags = {
    Name = "Bootstrapping Linux EC2 node with User Data"
  }
}

output "private_ip" {
  value = aws_instance.node.private_ip
}
