provider "aws" {
  default_tags {
    tags = {
      TerraformModuleTest = "complex"
    }
  }
}

variables {
  name_prefix    = "module-test-complex"
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

run "default" {
  assert {
    condition     = aws_vpc.this.cidr_block == "10.0.0.0/16"
    error_message = "need to check `aws_vpc` block."
  }

  assert {
    condition     = length(aws_subnet.this) == 6
    error_message = "need to check `aws_subnet` block."
  }

  assert {
    condition     = length(aws_route_table.this) == 6
    error_message = "need to check `aws_route_table` block."
  }

  assert {
    condition     = length(aws_route_table_association.this) == 6
    error_message = "need to check `aws_route_table_association` block."
  }

  assert {
    condition     = length(aws_internet_gateway.this) == 1
    error_message = "need to check `aws_internet_gateway` block."
  }

  assert {
    condition     = length(aws_nat_gateway.this) == 2
    error_message = "need to check `aws_nat_gateway` block."
  }
}
