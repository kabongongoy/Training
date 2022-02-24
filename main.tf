# Create a VPC
resource "aws_vpc" "TFT_VPC" {
  cidr_block           = "10.123.0.0/16"
  enable_dns_hostnames = true

  tags = {
    Name = "dev"
  }
}
resource "aws_subnet" "TFT_SUB" {
  vpc_id                  = aws_vpc.TFT_VPC.id
  cidr_block              = "10.123.1.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "us-east-1a"

  tags = {
    Name = "dev-public"
  }
}
resource "aws_internet_gateway" "TFT_IGW" {
  vpc_id = aws_vpc.TFT_VPC.id

  tags = {
    Name = "dev_igw"
  }
}
resource "aws_route_table" "TFT_RT" {
  vpc_id = aws_vpc.TFT_VPC.id

  tags = {
    Name = "dev_rt"
  }

}
resource "aws_route" "TFT_ROUTE" {
  route_table_id         = aws_route_table.TFT_RT.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.TFT_IGW.id
}
resource "aws_route_table_association" "TFT_RTA" {
  subnet_id      = aws_subnet.TFT_SUB.id
  route_table_id = aws_route_table.TFT_RT.id
}
resource "aws_security_group" "TFT_SG" {
  name        = "dev_sg"
  description = "dev security group"
  vpc_id      = aws_vpc.TFT_VPC.id

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["139.216.36.190/32"]

  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
resource "aws_key_pair" "TFT_KEY" {
  key_name   = "TFT-key"
  public_key = file("~/.ssh/TFT_KEY.pub")
}

resource "aws_instance" "TFT_INSTANCE" {
  instance_type          = "t2.micro"
  ami                    = data.aws_ami.TFT_AMI.id
  key_name               = aws_key_pair.TFT_KEY.id
  vpc_security_group_ids = [aws_security_group.TFT_SG.id]
  subnet_id              = aws_subnet.TFT_SUB.id

  root_block_device {
    volume_size = 10
  }
  
  tags = {
    name = "dev-node"
  }
  

provisioner "local-exec" {
    command = templatefile("windows-ssh-config.tpl", {
        hostname = self.public_ip,
        user = "ubuntu"
        identityfile = "~/.ssh/TFT_KEY"
    })
    interpreter = ["powershell", "-command" ]
}
}
