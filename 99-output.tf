output "vpc_id" {
  description = "The id of the VPC"
  value       = aws_vpc.this.id
}

output "subnet_ids" {
  description = "The dictioanry of the subnet id"
  value = {
    for identifier, subnet in aws_subnet.this :
    identifier => subnet.id
  }
}

output "subnet_cidr_blocks" {
  description = "The dictioanry of the subnet cidr-block"
  value = {
    for identifier, subnet in aws_subnet.this :
    identifier => subnet.cidr_block
  }
}

output "route_table_ids" {
  description = "The dictioanry of the route-table id"
  value = {
    for identifier, route_table in aws_route_table.this :
    identifier => route_table.id
  }
}

output "igw_gateway_id" {
  description = "The id of the internet gateway"
  value       = var.create_igw ? element(aws_internet_gateway.this, 0).id : null
}

output "natgw_ids" {
  description = "The dictioanry of the nat-gateway id"
  value = {
    for identifier, natgw in aws_nat_gateway.this :
    identifier => natgw.id
  }
}

output "natgw_ips" {
  description = "The dictioanry of the nat-gateway public-ips"
  value = {
    for identifier, natgw in aws_nat_gateway.this :
    identifier => natgw.public_ip
  }
}
