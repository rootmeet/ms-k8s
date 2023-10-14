terraform {
  required_version = ">= 1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
  }
}

provider "aws" {
    region = var.region
}

resource "aws_key_pair" "example" {
    key_name = "terraform-demo-sanjeev"
    public_key = file("id_rsa.pub")
}

resource "aws_vpc" "myvpc" {
    cidr_block = var.cidr
}


resource "aws_subnet" "mysubnet" {
    vpc_id  = aws_vpc.myvpc.id
    cidr_block = var.subnet-cidr
    availability_zone = "${var.region}a"
    map_public_ip_on_launch = true
}


resource "aws_internet_gateway" "myigw" {
    vpc_id = aws_vpc.myvpc.id
}

resource "aws_route_table" "myrt" {
    vpc_id = aws_vpc.myvpc.id
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.myigw.id
    }
}

resource "aws_route_table_association" "myrtassoc" {
    subnet_id = aws_subnet.mysubnet.id
    route_table_id = aws_route_table.myrt.id
}

resource "aws_security_group" "mysg" {
    name = "web"
    vpc_id = aws_vpc.myvpc.id

    ingress{
        description = "HTTP to VPC"
        from_port = 80
        to_port = 80
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    ingress{
        description = "HTTP to VPC"
        from_port = 443
        to_port = 443
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    ingress{
        description = "SSH"
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]        
    }
    egress{
        description = "Outbound Config"
        from_port = 0
        to_port = 0
        protocol = "-1" #"tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    tags = {
      name = "Web-SG"
    }
}

resource "aws_instance" "k8s-master" {
    instance_type = var.instance-type
    ami = var.ami
    subnet_id = aws_subnet.mysubnet.id
    key_name = aws_key_pair.example.key_name
    vpc_security_group_ids = [aws_security_group.mysg.id]

    tags = {
      Name = var.instance-master
    }

    connection {
        type        = "ssh"
        user        = "ubuntu"  # Replace with the appropriate username for your EC2 instance
        private_key = file("id_rsa")  # Replace with the path to your private key
        host        = self.public_ip
    }
  
    provisioner "remote-exec" {
        inline = [
        "sudo apt-get update -y",
        ]
    }
}

resource "aws_instance" "k8s-worker" {
    instance_type = var.instance-type
    ami = var.ami
    subnet_id = aws_subnet.mysubnet.id
    key_name = aws_key_pair.example.key_name
    vpc_security_group_ids = [aws_security_group.mysg.id]

    tags = {
      Name = var.instance-worker
    }

    connection {
        type        = "ssh"
        user        = "ubuntu"  # Replace with the appropriate username for your EC2 instance
        private_key = file("id_rsa")  # Replace with the path to your private key
        host        = self.public_ip
    }
  
    provisioner "remote-exec" {
        inline = [
        "sudo apt-get update -y",
        ]
    }
}