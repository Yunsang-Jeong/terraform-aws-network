terraform {
  # Terraform version
  required_version = ">= 1.3.0"
  required_providers {
    # AWS provider version
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0.0"
    }
  }
}