
variable "vpc_cidr_block" {}
variable "subnet_cidr_block" {}
variable "avail_zone" {}
variable "env_prefix" {}
variable "my_ip" {}
variable "instance_type" {}
variable "pub_key_loc" {}


resource "aws_vpc" "hoitcs-vpc" {
  cidr_block = var.vpc_cidr_block
  tags = {
    Name : "${var.env_prefix}-vpc"
  }
}
resource "aws_subnet" "hoitcs-subnet-1" {
  vpc_id            = aws_vpc.hoitcs-vpc.id
  cidr_block        = var.subnet_cidr_block
  availability_zone = var.avail_zone
  tags = {
    Name = "${var.env_prefix}-subnet1"
  }
}

/*resource "aws_route_table" "hoitcs-route-table" {
    vpc_id = aws_vpc.hoitcs-vpc.id

    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.hoitcs-internet-gateway.id
    }
    tags = {
        Name: "${var.env_prefix}-rt"
    }
}*/

resource "aws_default_route_table" "hoitcs-default-route-table" {
  default_route_table_id = aws_vpc.hoitcs-vpc.default_route_table_id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.hoitcs-internet-gateway.id
  }
  tags = {
    Name : "${var.env_prefix}-default-route-table"
  }
}


resource "aws_internet_gateway" "hoitcs-internet-gateway" {
  vpc_id = aws_vpc.hoitcs-vpc.id

  tags = {
    Name : "${var.env_prefix}-igw"
  }
}

/*resource "aws_route_table_association" "hoitcs-rtb-association" {
    subnet_id = aws_subnet.hoitcs-subnet-1.id
    route_table_id = aws_route_table.hoitcs-route-table.id
}*/

/*resource "aws_security_group" "hoitcs-sec-group" {
    name = "hoitcs-sec-group"
    vpc_id = aws_vpc.hoitcs-vpc.id

    ingress {
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = [var.my_ip]
    } 
    ingress {
        from_port = 8080
        to_port = 8080
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    } 
    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
        prefix_list_ids = []
    }
    tags = {
        Name: "${var.env_prefix}-sec-group"
    }
}*/

resource "aws_default_security_group" "hoitcs-default-sec-group" {
  vpc_id = aws_vpc.hoitcs-vpc.id

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
    Name : "${var.env_prefix}-default-sec-group"
  }
}

data "aws_ami" "latest-linux-ami" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

/*resource "aws_key_pair" "Hoitcs-default-KP" {
    key_name = "Hoitcs-default-KP"
    public_key = file(var.pub_key_loc)
}*/

resource "aws_instance" "hoitcs-ec2" {
  ami                         = data.aws_ami.latest-linux-ami.id
  instance_type               = var.instance_type
  subnet_id                   = aws_subnet.hoitcs-subnet-1.id
  vpc_security_group_ids      = [aws_default_security_group.hoitcs-default-sec-group.id]
  availability_zone           = var.avail_zone
  associate_public_ip_address = true
  key_name                    = var.pub_key_loc
  user_data                   = file("userdata-ngnix.sh")

  tags = {
    Name : "${var.env_prefix}-hoitcs-ec2"
  }
}


output "aws_ami_id" {
  value = data.aws_ami.latest-linux-ami.id
}

output "public_ip" {
  value = aws_instance.hoitcs-ec2.public_ip
}