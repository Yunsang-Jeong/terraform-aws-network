########################################
# Shared
variable "name_tag_convention" {
  description = "The name tag convention of all resources."
  type = object({
    project_name = string
    stage        = string
  })
  default = {
    project_name = "tf"
    stage        = "poc"
  }
}

variable "global_additional_tag" {
  description = "Additional tags for all resources."
  type        = map(string)
  default     = {}
}
########################################


########################################
# VPC
variable "vpc_cidr_block" {
  description = "The CIDR block for the VPC."
  type        = string
  default     = "10.0.0.0/16"
}

variable "vpc_assign_generated_ipv6_cidr_block" {
  description = "Requests an Amazon-provided IPv6 CIDR block with a /56 prefix length for the VPC."
  type        = bool
  default     = false
}

variable "vpc_enable_dns_hostnames" {
  description = "A boolean flag to enable/disable DNS hostnames in the VPC."
  type        = bool
  default     = false
}

variable "vpc_enable_dns_support" {
  description = "A boolean flag to enable/disable DNS support in the VPC."
  type        = bool
  default     = false
}

variable "vpc_instance_tenancy" {
  description = "A tenancy option for instances launched into the VPC. It can be either dedicated or host"
  type        = string
  default     = "default"
}

variable "vpc_tags" {
  description = "A map of tags to assign to the VPC."
  type        = map(string)
  default     = {}
}

variable "vpc_name_tag_postfix" {
  description = "The postfix of name tag for the VPC."
  type        = string
  default     = ""
}
########################################

########################################
# Internet-gateway
variable "create_igw" {
  description = "If true, internet-gateway will be created."
  type        = bool
  default     = false
}

variable "igw_tags" {
  description = "A map of tags to assign to the Internet-gateway."
  type        = map(string)
  default     = {}
}
########################################


########################################
# Subnets
variable "subnets" {
  description = "The subnet informations"
  type = list(object(
    {
      identifier                      = string
      availability_zone               = string
      cidr_block                      = string
      ipv6_cidr_block                 = optional(string)
      customer_owned_ipv4_pool        = optional(string)
      assign_ipv6_address_on_creation = optional(bool)
      map_customer_owned_ip_on_launch = optional(bool)
      map_public_ip_on_launch         = optional(bool)
      outpost_arn                     = optional(string)
      timeouts = optional(object(
        {
          create = string
          delete = string
        }
      ))
      # NAT GW
      create_nat            = optional(bool)
      enable_route_with_nat = optional(bool)
      enable_route_with_igw = optional(bool)
      # Tags
      additional_tag   = optional(map(string))
      name_tag_postfix = optional(string)
    }
  ))
}
########################################