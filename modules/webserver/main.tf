

resource "aws_security_group" "hoitcs-ngnix-sec-group" {
  vpc_id = var.vpc_id
  name = "hoitcs-ngnix-sec-group"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.my_ip]
  }
  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
    prefix_list_ids = []
  }
  tags = {
    Name : "${var.env_prefix}-ngnix-sec-group"
  }
}

data "aws_ami" "latest-linux-ami" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = [var.image_name]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}


resource "aws_instance" "hoitcs-ec2" {
  ami                         = data.aws_ami.latest-linux-ami.id
  instance_type               = var.instance_type
  subnet_id                   = var.subnet_id
  vpc_security_group_ids      = [aws_security_group.hoitcs-ngnix-sec-group.id]
  availability_zone           = var.availability_zone
  associate_public_ip_address = true
  key_name                    = var.pub_key_name
  user_data                   = file("userdata-ngnix.sh")

  tags = {
    Name : "${var.env_prefix}-hoitcs-ec2"
  }
}