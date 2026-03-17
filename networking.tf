resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr_block
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = merge(local.common_tags, {
    Name = "k8s-main-vpc"
  })
}

resource "aws_subnet" "public_subnet" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.public_subnet_cidr
  map_public_ip_on_launch = true

  tags = merge(local.common_tags, {
    Name = "k8s-public-subnet"
  })
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = merge(local.common_tags, {
    Name = "main-internet-gateway"
  })
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = merge(local.common_tags, {
    Name = "k8s-public-rt"
  })
}

resource "aws_route_table_association" "main" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.public.id
}

resource "aws_key_pair" "k8s" {
  key_name   = "k8s-key"
  public_key = file(var.public_ssh_key)
}

resource "aws_eip" "this" {
  count    = var.instance_count
  instance = aws_instance.this[count.index].id
  domain   = "vpc"

  tags = merge(local.common_tags, {
    Name = "k8s-eip-${count.index == 0 ? "master" : "worker-${count.index}"}"
  })
}