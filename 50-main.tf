########################################
# VPC

resource "aws_vpc" "this" {
  cidr_block           = var.vpc_cidr_block
  enable_dns_hostnames = var.vpc_enable_dns_hostnames
  enable_dns_support   = var.vpc_enable_dns_support
  tags = merge(
    var.global_additional_tag,
    var.vpc_tags,
    {
      "Name" = "${var.name_prefix}-vpc"
    }
  )
}
########################################


########################################
# Subnets with Route-tables

resource "aws_subnet" "this" {
  for_each = {
    for subnet in var.subnets :
    subnet.identifier => subnet
  }

  vpc_id            = aws_vpc.this.id
  availability_zone = each.value.availability_zone
  cidr_block        = each.value.cidr_block
  tags = merge(
    var.global_additional_tag,
    each.value.additional_tag,
    {
      "Name" = "${var.name_prefix}-${each.key}-subnet"
    }
  )
}

resource "aws_route_table" "this" {
  for_each = {
    for subnet in var.subnets :
    subnet.identifier => subnet
  }

  vpc_id = aws_vpc.this.id
  tags = merge(
    var.global_additional_tag,
    {
      "Name" = "${var.name_prefix}-${each.key}-rt"
    }
  )
}

resource "aws_route_table_association" "this" {
  for_each = {
    for subnet in var.subnets :
    subnet.identifier => subnet
  }

  subnet_id      = lookup(aws_subnet.this, each.key).id
  route_table_id = lookup(aws_route_table.this, each.key).id
}
########################################


########################################
# Internet-gateway, associate subnet with it

resource "aws_internet_gateway" "this" {
  count = var.create_igw ? 1 : 0

  vpc_id = aws_vpc.this.id
  tags = merge(
    var.global_additional_tag,
    var.igw_tags,
    {
      "Name" = "${var.name_prefix}-igw"
    }
  )
}

resource "aws_route" "route_with_igw" {
  for_each = {
    for subnet in var.subnets :
    subnet.identifier => subnet
    if var.create_igw && subnet.enable_route_with_igw
  }

  route_table_id         = lookup(aws_route_table.this, each.key).id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = element(aws_internet_gateway.this, 0).id
}
########################################


########################################
# NAT-gateway, associate subnet with it

resource "aws_eip" "this" {
  for_each = {
    for subnet in var.subnets :
    subnet.identifier => subnet
    if subnet.create_nat == true
  }

  domain = "vpc"
  tags = merge(
    var.global_additional_tag,
    {
      "Name" = "${var.name_prefix}-${each.key}-natgw-eip"
    }
  )
}

resource "aws_nat_gateway" "this" {
  for_each = {
    for subnet in var.subnets :
    subnet.identifier => subnet
    if subnet.create_nat == true
  }

  subnet_id     = lookup(aws_subnet.this, each.value.identifier).id
  allocation_id = lookup(aws_eip.this, each.value.identifier).id
  tags = merge(
    var.global_additional_tag,
    {
      "Name" = "${var.name_prefix}-${each.key}-natgw"
    }
  )
}

resource "aws_route" "route_with_natgw" {
  for_each = {
    for subnet in var.subnets :
    subnet.identifier => subnet
    if subnet.enable_route_with_nat && length(aws_nat_gateway.this) > 0
  }

  route_table_id         = lookup(aws_route_table.this, each.key).id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id = try(
    lookup(aws_nat_gateway.this, each.key).id,
    values(aws_nat_gateway.this)[0].id
  )
}
########################################
