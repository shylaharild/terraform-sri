provider "aws" {
  region = "us-east-1"
  profile = "${var.aws_profile}"
  # access_key = "${vars.aws_access_key}"
  # secret_key = "${vars.aws_secret_key}"
}

resource "aws_security_group" "web_server_sg" {
  name        = "web_instance_sg"
  description = "Web Server Security Group - ingress and egress rules given"

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow All Traffic"
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["176.248.24.249/32"]
    description = "Allow SSH to my ip"
  }

  ingress {
    from_port   = 21
    to_port     = 21
    protocol    = "tcp"
    cidr_blocks = ["176.248.24.249/32"]
    description = "Allow SSH to my ip"
  }

  ingress {
    from_port   = 25
    to_port     = 25
    protocol    = "tcp"
    cidr_blocks = ["176.248.24.249/32"]
    description = "Allow SSH to my ip"
  }

  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description     = "Allow 80 to all"
  }

  ingress {
    from_port       = 443
    to_port         = 443
    protocol        = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description     = "Allow 443 to all"
  }

  tags = {
    Name    = "web_server_sg"
  }
}

resource "aws_security_group" "app_server_sg" {
  name        = "app_instance_sg"
  description = "App Server Security Group - ingress and egress rules given"

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow All Traffic"
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["176.248.24.249/32"]
    description = "Allow SSH to my ip"
  }

  ingress {
    from_port   = 21
    to_port     = 21
    protocol    = "tcp"
    cidr_blocks = ["176.248.24.249/32"]
    description = "Allow SSH to my ip"
  }

  ingress {
    from_port   = 25
    to_port     = 25
    protocol    = "tcp"
    cidr_blocks = ["176.248.24.249/32"]
    description = "Allow SSH to my ip"
  }

  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    cidr_blocks = ["${aws_eip.web_server_ip.public_ip}/32"]
    description     = "Allow 80 to EIP"
  }

  ingress {
    from_port       = 443
    to_port         = 443
    protocol        = "tcp"
    cidr_blocks = ["${aws_eip.web_server_ip.public_ip}/32"]
    description     = "Allow 443 to EIP"
  }

  tags = {
    Name    = "app_server_sg"
  }

}

resource "aws_eip" "web_server_ip" {
   vpc = true
}

resource "aws_instance" "web_server" {
  ami = "ami-035be7bafff33b6b6"
  instance_type = "t2.micro"
  security_groups = ["${aws_security_group.web_server_sg.name}"]
  tags = {
    Name = "web_server"
  }
}

resource "aws_instance" "app_server" {
  ami = "ami-035be7bafff33b6b6"
  instance_type = "t2.micro"
  security_groups = ["${aws_security_group.app_server_sg.name}"]
  tags = {
    Name = "app_server"
  }
}

resource "aws_eip_association" "eip_assoc" {
  instance_id   = "${aws_instance.web_server.id}"
  allocation_id = "${aws_eip.web_server_ip.id}"
}
