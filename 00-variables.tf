########################################
# Shared

variable "name_prefix" {
  description = "The name-prefix of all resources."
  type        = string
  default     = "tf-poc"
}

variable "global_additional_tag" {
  description = "Additional tags for all resources."
  type        = map(string)
  default = {
    "TerraformModuleSource" = "github.com/Yunsang-Jeong/terraform-aws-network"
  }
}
########################################


########################################
# VPC

variable "vpc_cidr_block" {
  description = "The CIDR block for the VPC."
  type        = string
  default     = "10.0.0.0/16"
}

variable "vpc_enable_dns_hostnames" {
  description = "A boolean flag to enable/disable DNS hostnames in the VPC."
  type        = bool
  default     = true
}

variable "vpc_enable_dns_support" {
  description = "A boolean flag to enable/disable DNS support in the VPC."
  type        = bool
  default     = true
}

variable "vpc_tags" {
  description = "A map of tags to assign to the vpc."
  type        = map(string)
  default     = {}
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
      identifier            = string
      availability_zone     = string
      cidr_block            = string
      create_nat            = optional(bool, false)
      enable_route_with_igw = optional(bool, false)
      enable_route_with_nat = optional(bool, false)
      additional_tag        = optional(map(string), {})
    }
  ))
  default = []

  validation {
    condition = alltrue([
      for subnet in var.subnets :
      !(subnet.enable_route_with_igw && subnet.enable_route_with_nat)
    ])
    error_message = "Only one of `enable_route_with_igw` and `enable_route_with_nat` can be true."
  }
}
########################################
