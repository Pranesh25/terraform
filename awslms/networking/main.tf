#### networking module #######

data "aws_availability_zones" "az" {}



resource "random_integer" "random" {
  min = 1
  max = 50

}


resource "random_shuffle" "shuffle" {

  input        = data.aws_availability_zones.az.names
  result_count = var.max_subnets

}


resource "aws_vpc" "pranesh_vpc" {

  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true


  tags = {
    Name = "pranesh-vpc-${random_integer.random.id}"
  }

  lifecycle {
    create_before_destroy = true
  }

}


resource "aws_subnet" "pranesh_public_subnets" {
  count                   = var.public_subnet_count
  vpc_id                  = aws_vpc.pranesh_vpc.id
  cidr_block              = var.public_cidrs[count.index]
  map_public_ip_on_launch = true
  # availability_zone = "us-east-1a"
  availability_zone = random_shuffle.shuffle.result[count.index]

  tags = {
    "Name" = "public_subnet_${count.index + 1}"
  }

}

resource "aws_route_table_association" "public_rt_association" {
  count          = var.public_subnet_count
  subnet_id      = aws_subnet.pranesh_public_subnets.*.id[count.index]
  route_table_id = aws_route_table.public_rt.id

}


resource "aws_subnet" "pranesh_private_subnets" {
  count                   = var.private_subnet_count
  vpc_id                  = aws_vpc.pranesh_vpc.id
  cidr_block              = var.private_cidrs[count.index]
  map_public_ip_on_launch = false
  # availability_zone = data.aws_availability_zones.az.names[count.index]
  availability_zone = random_shuffle.shuffle.result[count.index]
  # availability_zone = "us-east-1a"


  tags = {
    "Name" = "private_subnet_${count.index + 1}"
  }

}


resource "aws_internet_gateway" "igw" {

  vpc_id = aws_vpc.pranesh_vpc.id

  tags = {
    "Name" = "pranesh-igw"
  }
}


resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.pranesh_vpc.id

  tags = {
    "Name" = "pranesh-rt-pub"
  }

}

resource "aws_route" "default_route" {

  route_table_id         = aws_route_table.public_rt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id

}

resource "aws_default_route_table" "private_route_table" {
  default_route_table_id = aws_vpc.pranesh_vpc.default_route_table_id

  tags = {
    "Name" = "private_route_vpc_default_route_table"
  }

}


resource "aws_security_group" "pranesh_sg" {


  for_each = var.security_groups

  name        = each.value.name
  description = each.value.description
  vpc_id      = aws_vpc.pranesh_vpc.id

  dynamic "ingress" {
    for_each = each.value.ingress
    content {

      from_port   = ingress.value.from
      to_port     = ingress.value.to
      protocol    = ingress.value.protocol
      cidr_blocks = ingress.value.cidr_block
    }

  }

  egress {

    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

}



resource "aws_db_subnet_group" "rds_subnetgroup" {

  count = var.aws_db_subnet_group == true ? 1 : 0

  name = "rds_subnet_group"
  subnet_ids = aws_subnet.pranesh_private_subnets.*.id
  tags = {
    "Name" = "db_subnet"
  }
  
}