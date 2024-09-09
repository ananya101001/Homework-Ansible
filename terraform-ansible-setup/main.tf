terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }
}

provider "aws" {
  region  = "us-west-1"
}

resource "tls_private_key" "key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "key_pair" {
  key_name   = "key"
  public_key = tls_private_key.key.public_key_openssh

  provisioner "local-exec" {
    command = "echo '${tls_private_key.key.private_key_pem}' > ${path.module}/key.pem && chmod 0700 ${path.module}/key.pem"
  }
}

data "aws_security_group" "existing_sg" {
  name   = "allow_ssh_http"  # Replace with your security group name
  vpc_id = "vpc-08fc6bc8a979b800d" 
}

resource "aws_instance" "VM1" {
  ami           = "ami-0d53d72369335a9d6"  # Ubuntu 22.04 free tier ami in us-west-1
  instance_type = "t2.nano"
  key_name = aws_key_pair.key_pair.key_name
  availability_zone = "us-west-1b"
  vpc_security_group_ids = [data.aws_security_group.existing_sg.id]
}

resource "aws_instance" "VM2" {
  ami           = "ami-0d53d72369335a9d6"  # Ubuntu 22.04 free tier ami in us-west-1
  instance_type = "t2.nano"
  key_name = aws_key_pair.key_pair.key_name
  availability_zone = "us-west-1b"
  vpc_security_group_ids = [data.aws_security_group.existing_sg.id]
}


