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
