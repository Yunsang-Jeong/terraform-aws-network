########################################
# VPC
resource "aws_vpc" "this" {
  cidr_block                       = var.vpc_cidr_block
  assign_generated_ipv6_cidr_block = var.vpc_assign_generated_ipv6_cidr_block
  enable_dns_hostnames             = var.vpc_enable_dns_hostnames
  enable_dns_support               = var.vpc_enable_dns_support
  instance_tenancy                 = var.vpc_instance_tenancy
  tags = merge(
    var.global_additional_tag,
    var.vpc_tags,
    {
      "Name" = join("-", compact(["vpc", local.name_tag_middle, var.vpc_name_tag_postfix]))
    }
  )
}
########################################


########################################
# Subnets
resource "aws_subnet" "this" {
  for_each = { for subnet in var.subnets : subnet.identifier => subnet }

  vpc_id                          = aws_vpc.this.id
  availability_zone               = each.value.availability_zone
  cidr_block                      = each.value.cidr_block
  ipv6_cidr_block                 = each.value.ipv6_cidr_block
  assign_ipv6_address_on_creation = each.value.assign_ipv6_address_on_creation
  customer_owned_ipv4_pool        = each.value.customer_owned_ipv4_pool
  map_customer_owned_ip_on_launch = each.value.map_customer_owned_ip_on_launch
  map_public_ip_on_launch         = each.value.map_public_ip_on_launch
  outpost_arn                     = each.value.outpost_arn

  dynamic "timeouts" {
    for_each = each.value.timeouts == null ? toset([]) : toset([each.value.timeouts])
    content {
      create = timeouts.value["create"]
      delete = timeouts.value["delete"]
    }
  }

  tags = merge(
    var.global_additional_tag,
    each.value.additional_tag,
    {
      "Name" = join("-", compact(["sub", local.name_tag_middle, each.value.name_tag_postfix != null ? each.value.name_tag_postfix : ""]))
    }
  )
}
########################################


########################################
# Internet-gateway, Route table for it and associate subnet with it
resource "aws_internet_gateway" "this" {
  for_each = var.create_igw == true ? toset(["this"]) : toset([])

  vpc_id = aws_vpc.this.id
  tags = merge(
    var.global_additional_tag,
    var.igw_tags,
    {
      "Name" = join("-", compact(["igw", local.name_tag_middle]))
    }
  )
}

resource "aws_route_table" "route_table_igw" {
  for_each = var.create_igw == true ? toset(["this"]) : toset([])

  vpc_id = aws_vpc.this.id
  tags = merge(
    var.global_additional_tag,
    {
      "Name" = join("-", compact(["rt", local.name_tag_middle, "igw"]))
    }
  )
}

resource "aws_route" "route_table_igw" {
  for_each = var.create_igw == true ? toset(["this"]) : toset([])

  route_table_id         = aws_route_table.route_table_igw["this"].id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.this["this"].id
}

resource "aws_route_table_association" "route_table_igw" {
  for_each = { for subnet in var.subnets : subnet.identifier => subnet if var.create_igw == true && subnet.enable_route_with_igw == true }

  subnet_id      = lookup(aws_subnet.this, each.value.identifier).id
  route_table_id = aws_route_table.route_table_igw["this"].id
}
########################################


########################################
# NAT-gateway, Route table for it and associate subnet with it
resource "aws_nat_gateway" "this" {
  for_each = { for subnet in var.subnets : subnet.identifier => subnet if subnet.create_nat == true }

  subnet_id     = lookup(aws_subnet.this, each.value.identifier).id
  allocation_id = lookup(aws_eip.this, each.value.identifier).id
  tags = merge(
    var.global_additional_tag,
    {
      "Name" = join("-", compact(["nat", local.name_tag_middle, each.value.name_tag_postfix != null ? each.value.name_tag_postfix : ""]))
    }
  )
}

resource "aws_eip" "this" {
  for_each = { for subnet in var.subnets : subnet.identifier => subnet if subnet.create_nat == true }

  vpc = true
  tags = merge(
    var.global_additional_tag,
    {
      "Name" = join("-", compact(["eip", local.name_tag_middle, "nat", each.value.name_tag_postfix != null ? each.value.name_tag_postfix : ""]))
    }
  )
}

resource "aws_route_table" "route_table_nat" {
  for_each = { for subnet in var.subnets : subnet.identifier => subnet if subnet.create_nat == true }

  vpc_id = aws_vpc.this.id
  tags = merge(
    var.global_additional_tag,
    {
      "Name" = join("-", compact(["rt", local.name_tag_middle, "nat", each.value.name_tag_postfix != null ? each.value.name_tag_postfix : ""]))
    }
  )
}

resource "aws_route" "route_table_nat" {
  for_each = { for subnet in var.subnets : subnet.identifier => subnet if subnet.create_nat == true }

  route_table_id         = lookup(aws_route_table.route_table_nat, each.value.identifier).id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = lookup(aws_nat_gateway.this, each.value.identifier).id
}

locals {
  route_table_nat_by_az = transpose({
    for identifier in keys(aws_route_table.route_table_nat) : lookup(aws_route_table.route_table_nat, identifier).id => [lookup(aws_subnet.this, identifier).availability_zone]
  })
}

resource "aws_route_table_association" "route_table_nat" {
  for_each = { for subnet in var.subnets : subnet.identifier => subnet if subnet.enable_route_with_nat == true && length(aws_nat_gateway.this) > 0 }

  subnet_id      = lookup(aws_subnet.this, each.key).id
  route_table_id = can(local.route_table_nat_by_az[each.value.availability_zone]) ? lookup(local.route_table_nat_by_az, each.value.availability_zone)[0] : flatten(values(local.route_table_nat_by_az))[0]
}
########################################


########################################
# Route table for isolated subnet and associate subnet with it
locals {
  isolated_subnets = { for subnet in var.subnets : subnet.identifier => subnet if subnet.enable_route_with_igw != true && subnet.enable_route_with_nat != true }
}

resource "aws_route_table" "route_table_iso" {
  for_each = length(local.isolated_subnets) > 0 ? toset(["this"]) : toset([])

  vpc_id = aws_vpc.this.id
  tags = merge(
    var.global_additional_tag,
    {
      "Name" = join("-", compact(["rt", local.name_tag_middle, "iso"]))
    }
  )
}

resource "aws_route_table_association" "route_table_iso" {
  for_each = local.isolated_subnets

  subnet_id      = lookup(aws_subnet.this, each.value.identifier).id
  route_table_id = aws_route_table.route_table_iso["this"].id
}
########################################