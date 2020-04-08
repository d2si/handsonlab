data "aws_availability_zones" "available" {}

######
# VPC
######
resource "aws_vpc" "vpc" {
  cidr_block = var.cidr_block
  tags       = merge({"Name" = format("vpc-%s", var.name)}, var.tags)
}

##################
# INTERNET GATEWAY
##################
resource "aws_internet_gateway" "internet_gateway" {
  vpc_id = aws_vpc.vpc.id
  tags   = merge({"Name" = format("igw-%s", var.name)}, var.tags)
}

################
# SUBNET PUBLIC
################
locals {
  subnet_priv = element(concat(aws_subnet.public.*.id, [""], ), 0, )
}

resource "aws_subnet" "public" {
  count = length(var.subnet_pub_cidr_list)

  vpc_id            = aws_vpc.vpc.id
  cidr_block        = element(var.subnet_pub_cidr_list, count.index)
  availability_zone = element(data.aws_availability_zones.available.names, count.index)
  tags              = merge({"Name" = format("subnet-pub-%s", element(data.aws_availability_zones.available.names, count.index)) }, var.tags)
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.vpc.id
  tags   = merge({"Name" = format("rt-pub-%s", var.name)}, var.tags)
}

resource "aws_route" "public" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.internet_gateway.id
}

resource "aws_route_table_association" "public" {
  count = length(var.subnet_pub_cidr_list)

  subnet_id      = element(aws_subnet.public.*.id, count.index)
  route_table_id = aws_route_table.public.id
}

#########
# EIP
#########
resource "aws_eip" "eip" {
  vpc    = true
  tags   = merge({"Name" = format("eip-%s", var.name)}, var.tags)
}

#############
# NAT GATEWAY
#############
resource "aws_nat_gateway" "nat_gateway" {
  allocation_id = aws_eip.eip.id
  subnet_id     = local.subnet_priv
  tags          = merge({"Name" = format("nat-%s", var.name)}, var.tags)

  depends_on = ["aws_internet_gateway.internet_gateway"]
}

################
# SUBNET PRIVATE
################
resource "aws_subnet" "private" {
  count = length(var.subnet_priv_cidr_list)

  vpc_id            = aws_vpc.vpc.id
  cidr_block        = element(var.subnet_priv_cidr_list, count.index)
  availability_zone = element(data.aws_availability_zones.available.names, count.index)
  tags              = merge({"Name" = format("subnet-priv-%s", element(data.aws_availability_zones.available.names, count.index)) }, var.tags)
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.vpc.id

  tags   = merge({"Name" = format("rt-priv-%s", var.name)}, var.tags)
}

resource "aws_route" "private" {
  route_table_id         = aws_route_table.private.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat_gateway.id
}

resource "aws_route_table_association" "private" {
  count = length(var.subnet_priv_cidr_list)

  subnet_id      = element(aws_subnet.private.*.id, count.index)
  route_table_id = aws_route_table.private.id
}
