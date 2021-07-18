output "vpc_id" {
  description = "The id of the VPC"
  value       = aws_vpc.this.id
}

output "subnet_ids" {
  description = "The dictioanry of the subnet id"
  value       = { for identifier, subnet in aws_subnet.this : identifier => subnet.id }
}

output "igw_gateway_id" {
  description = "The id of the internet gateway"
  value       = var.create_igw == true ? aws_internet_gateway.this["this"].id : null
}

output "nat_gateway_ids" {
  description = "The dictioanry of the nat-gateway id"
  value       = { for identifier, natgw in aws_nat_gateway.this : identifier => natgw.id }
}

output "route_table_igw_id" {
  description = "The id of the route table for igw"
  value       = var.create_igw == true ? aws_route_table.route_table_igw["this"].id : null
}

output "route_table_nat_ids" {
  description = "The dictioanry of the route table id for nat"
  value       = { for identifier, rt in aws_route_table.route_table_nat : identifier => rt.id }
}

output "route_table_iso_id" {
  description = "The id of the route table for isolated subnet"
  value       = length(local.isolated_subnets) > 0 ? aws_route_table.route_table_iso["this"].id : null
}
