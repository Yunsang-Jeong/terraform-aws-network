# Overview

AWS VPC 및 Subnet, Route-table, Internet-Gateway, NAT-Gateway(EIP)을 생성하는 테라폼 모듈입니다. 하단의 내용은 `terraform-docs`에 의해 생성되었습니다.

<!-- BEGIN_TF_DOCS -->
## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 5.23.1 |

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.6.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 5.0.0 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_create_igw"></a> [create\_igw](#input\_create\_igw) | If true, internet-gateway will be created. | `bool` | `false` | no |
| <a name="input_global_additional_tag"></a> [global\_additional\_tag](#input\_global\_additional\_tag) | Additional tags for all resources. | `map(string)` | <pre>{<br>  "TerraformModuleSource": "github.com/Yunsang-Jeong/terraform-aws-network"<br>}</pre> | no |
| <a name="input_igw_tags"></a> [igw\_tags](#input\_igw\_tags) | A map of tags to assign to the Internet-gateway. | `map(string)` | `{}` | no |
| <a name="input_name_prefix"></a> [name\_prefix](#input\_name\_prefix) | The name-prefix of all resources. | `string` | `"tf-poc"` | no |
| <a name="input_subnets"></a> [subnets](#input\_subnets) | The subnet informations | <pre>list(object(<br>    {<br>      identifier            = string<br>      availability_zone     = string<br>      cidr_block            = string<br>      create_nat            = optional(bool, false)<br>      enable_route_with_igw = optional(bool, false)<br>      enable_route_with_nat = optional(bool, false)<br>      additional_tag        = optional(map(string), {})<br>    }<br>  ))</pre> | `[]` | no |
| <a name="input_vpc_cidr_block"></a> [vpc\_cidr\_block](#input\_vpc\_cidr\_block) | The CIDR block for the VPC. | `string` | `"10.0.0.0/16"` | no |
| <a name="input_vpc_enable_dns_hostnames"></a> [vpc\_enable\_dns\_hostnames](#input\_vpc\_enable\_dns\_hostnames) | A boolean flag to enable/disable DNS hostnames in the VPC. | `bool` | `true` | no |
| <a name="input_vpc_enable_dns_support"></a> [vpc\_enable\_dns\_support](#input\_vpc\_enable\_dns\_support) | A boolean flag to enable/disable DNS support in the VPC. | `bool` | `true` | no |
| <a name="input_vpc_tags"></a> [vpc\_tags](#input\_vpc\_tags) | A map of tags to assign to the vpc. | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_igw_gateway_id"></a> [igw\_gateway\_id](#output\_igw\_gateway\_id) | The id of the internet gateway |
| <a name="output_natgw_ids"></a> [natgw\_ids](#output\_natgw\_ids) | The dictioanry of the nat-gateway id |
| <a name="output_natgw_ips"></a> [natgw\_ips](#output\_natgw\_ips) | The dictioanry of the nat-gateway public-ips |
| <a name="output_route_table_ids"></a> [route\_table\_ids](#output\_route\_table\_ids) | The dictioanry of the route-table id |
| <a name="output_subnet_ids"></a> [subnet\_ids](#output\_subnet\_ids) | The dictioanry of the subnet id |
| <a name="output_vpc_id"></a> [vpc\_id](#output\_vpc\_id) | The id of the VPC |

## Example
```hcl
module "network" {
  source = "github.com/Yunsang-Jeong/terraform-aws-network"

  vpc_cidr_block = "10.0.0.0/16"
  create_igw     = true
  subnets = [
    {
      identifier            = "public-a"
      availability_zone     = "ap-northeast-2a"
      cidr_block            = "10.0.10.0/24"
      enable_route_with_igw = true
      create_nat            = true
    },
    {
      identifier            = "public-c"
      availability_zone     = "ap-northeast-2c"
      cidr_block            = "10.0.11.0/24"
      enable_route_with_igw = true
      create_nat            = true
    },
    {
      identifier            = "private-a"
      availability_zone     = "ap-northeast-2a"
      cidr_block            = "10.0.20.0/24"
      enable_route_with_nat = true
    },
    {
      identifier            = "private-c"
      availability_zone     = "ap-northeast-2c"
      cidr_block            = "10.0.21.0/24"
      enable_route_with_nat = true
    },
    {
      identifier        = "isolated-a"
      availability_zone = "ap-northeast-2a"
      cidr_block        = "10.0.30.0/24"
    },
    {
      identifier        = "isolated-c"
      availability_zone = "ap-northeast-2c"
      cidr_block        = "10.0.31.0/24"
    },
  ]
}
```
<!-- END_TF_DOCS -->