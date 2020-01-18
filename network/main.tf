provider "aws" {
  version = "~> 2.0"
  region  = "ap-northeast-2"
}

terraform {
  backend "s3" {
    bucket = "input-terraform-bucket"
    key    = "network/seoul"
    region = "ap-northeast-2"
  }
}

module "vpc_seoul" {
  source = "../modules/vpc"

  region = "ap-northeast-2"
  name = "seoul-vpc"
  cidr = "10.0.0.0/16"

  azs             = ["ap-northeast-2a", "ap-northeast-2c"]
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24"]
  public_subnets  = ["10.0.10.0/24", "10.0.20.0/24"]

  enable_nat_gateway = true
  enable_vpn_gateway = true
}

module "vpc_virginia" {
  source = "../modules/vpc"

  region = "us-east-1"
  name = "virginia-vpc"
  cidr = "10.1.0.0/16"

  azs             = ["us-east-1a", "us-east-1b"]
  private_subnets = ["10.1.1.0/24", "10.1.2.0/24"]
  public_subnets  = ["10.1.10.0/24", "10.1.20.0/24"]

  enable_nat_gateway = true
  enable_vpn_gateway = false
}

resource "aws_ec2_transit_gateway" "this" {
}

resource "aws_ec2_transit_gateway_vpc_attachment" "seoul" {
  subnet_ids = module.vpc_seoul.private_subnets 
  transit_gateway_id = aws_ec2_transit_gateway.this.id
  vpc_id = module.vpc_seoul.vpc_id
}

resource "aws_ec2_transit_gateway_vpc_attachment" "virginia" {
  subnet_ids = module.vpc_virginia.private_subnets 
  transit_gateway_id = aws_ec2_transit_gateway.this.id
  vpc_id = module.vpc_virginia.vpc_id
}

resource "aws_customer_gateway" "this" {
  bgp_asn    = 65000
  ip_address = var.cgw_ip_address
  type       = "ipsec.1"
}

resource "aws_vpn_connection" "this" {
  customer_gateway_id = aws_customer_gateway.this.id
  transit_gateway_id = aws_ec2_transit_gateway.this.id
  type = aws_customer_gateway.this.type
}

resource "aws_route" "seoul_privates" {
  count = length(module.vpc_seoul.private_route_table_ids)

  route_table_id = module.vpc_seoul.private_route_table_ids[count.index]
  destination_cidr_block = "10.0.0.0/8"
  transit_gateway_id = aws_ec2_transit_gateway.this.id
}

resource "aws_route" "seoul_publics" {
  count = length(module.vpc_seoul.public_route_table_ids)

  route_table_id = module.vpc_seoul.private_route_table_ids[count.index]
  destination_cidr_block = "10.0.0.0/8"
  transit_gateway_id = aws_ec2_transit_gateway.this.id
}

resource "aws_route" "virginia_privates" {
  count = length(module.vpc_virginia.private_route_table_ids)

  route_table_id = module.vpc_virginia.private_route_table_ids[count.index]
  destination_cidr_block = "10.0.0.0/8"
  transit_gateway_id = aws_ec2_transit_gateway.this.id
}

resource "aws_route" "virginia_publics" {
  count = length(module.vpc_virginia.public_route_table_ids)

  route_table_id = module.vpc_virginia.private_route_table_ids[count.index]
  destination_cidr_block = "10.0.0.0/8"
  transit_gateway_id = aws_ec2_transit_gateway.this.id
}
