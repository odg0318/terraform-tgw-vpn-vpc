variable "region" {
  type = string
}

variable "name" {
  type = string
}

variable "cidr" {
  type = string
}

variable "azs" {
  type = list(string)
  default = []
}

variable "public_subnets" {
  type = list(string)
  default = []
}

variable "private_subnets" {
  type = list(string)
  default = []
}

variable "enable_nat_gateway" {
  type = bool
  default = false
}

variable "enable_vpn_gateway" {
  type = bool
  default = false
}

variable "tags" {
  type = map(string)
  default = {}
}
