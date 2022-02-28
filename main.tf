module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = var.vpc_name
  cidr = var.vpc_cidr_block

  azs             = [var.availability_zone]
  public_subnets  = [var.subnet_cidr_block]
  public_subnet_tags = { Name = "${var.env_prefix}-subnet-1" }


  tags = {
    Name = "${var.env_prefix}-vpc"
  }
}




module "hoitcs-ngnix" {
  source ="./modules/webserver"
  my_ip = var.my_ip
  vpc_id = module.vpc.vpc_id
  subnet_id = module.vpc.public_subnets[0]
  env_prefix = var.env_prefix
  pub_key_name = var.pub_key_name
  instance_type = var.instance_type
  image_name = var.image_name
  availability_zone = var.availability_zone
  
}

/*resource "aws_key_pair" "Hoitcs-default-KP" {
    key_name = "Hoitcs-default-KP"
    public_key = file(var.pub_key_loc)
}*/