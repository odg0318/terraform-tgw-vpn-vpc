output vpc_id {
  value = module.this.vpc_id
}

output public_subnets {
  value = module.this.public_subnets
}

output private_subnets {
  value = module.this.private_subnets
}

output public_route_table_ids {
  value = module.this.public_route_table_ids
}

output private_route_table_ids {
  value = module.this.public_route_table_ids
}
