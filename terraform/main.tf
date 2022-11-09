terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}

provider "aws" {
  region = var.AWS_REGION
}

variable AWS_REGION{
  type = string
}

variable SUBNET_LETTER{
  type = string
  default = "a"
}

variable NUMBER_OF_RUNNERS {
  type = string
}

variable SSH_PUBLIC_KEY {
  type = string
}

resource "aws_default_subnet" "def_subnet" {
  availability_zone = "${var.AWS_REGION}${var.SUBNET_LETTER}"
}

resource "aws_security_group" "gitlab-sg" {
  name = "gitlab-sg"
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

resource "aws_key_pair" "deployer" {
  key_name   = "deployer-key"
  public_key = var.SSH_PUBLIC_KEY
}

resource "aws_instance" "runner" {
    ami = "ami-0a8e758f5e873d1c1"
    instance_type = "t2.micro"
    key_name = aws_key_pair.deployer.key_name
    subnet_id = aws_default_subnet.def_subnet.id
    vpc_security_group_ids = [aws_security_group.gitlab-sg.id]
    associate_public_ip_address = true
    count = var.NUMBER_OF_RUNNERS

}

output "instance_ips" {
  value = ["${aws_instance.runner.*.public_ip}"]
}

resource "local_file" "instance-ip" { 
  filename = "./instance_ips.ini"
  content = "${join("\n", aws_instance.runner.*.public_ip)}"
}
