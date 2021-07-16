# Overview

AWS VPC 및 Subnet, Route-table, Internet-Gateway, NAT-Gateway(EIP)을 생성하는 테라폼 모듈입니다. 하단의 내용은 `terraform-docs`에 의해 생성되었습니다.

<!-- BEGIN_TF_DOCS -->
## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 3.50.0 |

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 0.14.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 3.25.0 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_create_igw"></a> [create\_igw](#input\_create\_igw) | If true, internet-gateway will be created. | `bool` | `false` | no |
| <a name="input_global_additional_tag"></a> [global\_additional\_tag](#input\_global\_additional\_tag) | Additional tags for all resources. | `map(string)` | `{}` | no |
| <a name="input_igw_tags"></a> [igw\_tags](#input\_igw\_tags) | A map of tags to assign to the Internet-gateway. | `map(string)` | `{}` | no |
| <a name="input_name_tag_convention"></a> [name\_tag\_convention](#input\_name\_tag\_convention) | The name tag convention of all resources. | <pre>object({<br>    project_name   = string<br>    stage          = string<br>  })</pre> | <pre>{<br>  "project_name": "tf",<br>  "stage": "poc"<br>}</pre> | no |
| <a name="input_subnets"></a> [subnets](#input\_subnets) | The subnet informations | <pre>list(object(<br>    {<br>      identifier            = string<br>      availability_zone     = string<br>      cidr_block            = string<br>      ipv6_cidr_block       = optional(string)<br>      customer_owned_ipv4_pool = optional(string)<br>      assign_ipv6_address_on_creation = optional(bool)<br>      map_customer_owned_ip_on_launch  = optional(bool)<br>      map_public_ip_on_launch  = optional(bool)<br>      outpost_arn  = optional(string)<br>      timeouts = optional(object(<br>        {<br>          create = string<br>          delete = string<br>        }<br>      ))<br>      # NAT GW<br>      create_nat            = optional(bool)<br>      enable_route_with_nat = optional(bool)<br>      enable_route_with_igw = optional(bool)<br>      # Tags<br>      additional_tag        = optional(map(string))<br>      name_tag_postfix      = optional(string)<br>    }<br>  ))</pre> | n/a | yes |
| <a name="input_vpc_assign_generated_ipv6_cidr_block"></a> [vpc\_assign\_generated\_ipv6\_cidr\_block](#input\_vpc\_assign\_generated\_ipv6\_cidr\_block) | Requests an Amazon-provided IPv6 CIDR block with a /56 prefix length for the VPC. | `bool` | `false` | no |
| <a name="input_vpc_cidr_block"></a> [vpc\_cidr\_block](#input\_vpc\_cidr\_block) | The CIDR block for the VPC. | `string` | `"10.0.0.0/16"` | no |
| <a name="input_vpc_enable_dns_hostnames"></a> [vpc\_enable\_dns\_hostnames](#input\_vpc\_enable\_dns\_hostnames) | A boolean flag to enable/disable DNS hostnames in the VPC. | `bool` | `false` | no |
| <a name="input_vpc_enable_dns_support"></a> [vpc\_enable\_dns\_support](#input\_vpc\_enable\_dns\_support) | A boolean flag to enable/disable DNS support in the VPC. | `bool` | `false` | no |
| <a name="input_vpc_instance_tenancy"></a> [vpc\_instance\_tenancy](#input\_vpc\_instance\_tenancy) | A tenancy option for instances launched into the VPC. It can be either dedicated or host | `string` | `"default"` | no |
| <a name="input_vpc_name_tag_postfix"></a> [vpc\_name\_tag\_postfix](#input\_vpc\_name\_tag\_postfix) | The postfix of name tag for the VPC. | `string` | `""` | no |
| <a name="input_vpc_tags"></a> [vpc\_tags](#input\_vpc\_tags) | A map of tags to assign to the VPC. | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_igw_gateway_id"></a> [igw\_gateway\_id](#output\_igw\_gateway\_id) | The id of the internet gateway |
| <a name="output_nat_gateway_ids"></a> [nat\_gateway\_ids](#output\_nat\_gateway\_ids) | The dictioanry of the nat-gateway id |
| <a name="output_route_table_igw_id"></a> [route\_table\_igw\_id](#output\_route\_table\_igw\_id) | The id of the route table for igw |
| <a name="output_route_table_iso_id"></a> [route\_table\_iso\_id](#output\_route\_table\_iso\_id) | The id of the route table for isolated subnet |
| <a name="output_route_table_nat_ids"></a> [route\_table\_nat\_ids](#output\_route\_table\_nat\_ids) | The dictioanry of the route table id for nat |
| <a name="output_subnet_ids"></a> [subnet\_ids](#output\_subnet\_ids) | The dictioanry of the subnet id |
| <a name="output_vpc_id"></a> [vpc\_id](#output\_vpc\_id) | The id of the VPC |

## Example
```hcl
vpc_cidr_block = "10.0.0.0/16"
create_igw = true
subnets = [
{
    identifier            = "public-a"
    name_tag_postfix      = "pub-a"
    availability_zone     = "ap-northeast-2a"
    cidr_block            = "10.0.104.0/24"
    enable_route_with_igw = true
    create_nat            = true
},
{
    identifier            = "public-c"
    name_tag_postfix      = "pub-c"
    availability_zone     = "ap-northeast-2c"
    cidr_block            = "10.0.105.0/24"
    enable_route_with_igw = true
},
{
    identifier            = "private-web-a"
    name_tag_postfix      = "pri-web-a"
    availability_zone     = "ap-northeast-2a"
    cidr_block            = "10.0.106.0/24"
    enable_route_with_nat = true
},
{
    identifier            = "private-web-c"
    name_tag_postfix      = "pri-web-c"
    availability_zone     = "ap-northeast-2c"
    cidr_block            = "10.0.107.0/24"
    enable_route_with_nat = true
},
{
    identifier            = "private-was-a"
    name_tag_postfix      = "pri-was-a"
    availability_zone     = "ap-northeast-2a"
    cidr_block            = "10.0.108.0/24"
    enable_route_with_nat = true
},
{
    identifier            = "private-was-c"
    name_tag_postfix      = "pri-was-c"
    availability_zone     = "ap-northeast-2c"
    cidr_block            = "10.0.109.0/24"
    enable_route_with_nat = true
},
{
    identifier        = "private-db-a"
    name_tag_postfix  = "pri-db-a"
    availability_zone = "ap-northeast-2a"
    cidr_block        = "10.0.110.0/24"
},
{
    identifier        = "private-db-c"
    name_tag_postfix  = "pri-db-c"
    availability_zone = "ap-northeast-2c"
    cidr_block        = "10.0.111.0/24"
}
]
```
<!-- END_TF_DOCS -->