module "networks" {
  source = "./modules/networks"

  net1_name = var.net1_name
  net2_name = var.net2_name
  net3_name = var.net3_name

  subnet1_cidr = var.subnet1_cidr
  subnet2_cidr = var.subnet2_cidr
  subnet3_cidr = var.subnet3_cidr

  dns_nameservers = var.dns_nameservers

  subnet1_nexthop         = var.subnet1_nexthop
  subnet2_nexthop_to_net1 = var.subnet2_nexthop_to_net1
  subnet2_nexthop_to_net3 = var.subnet2_nexthop_to_net3
  subnet3_nexthop         = var.subnet3_nexthop
}

module "routers" {
  source           = "./modules/routers"
  external_network = var.external_network
  net1_id          = module.networks.net1_id
  net2_id          = module.networks.net2_id
  subnet1_id       = module.networks.subnet1_id
  subnet2_id       = module.networks.subnet2_id
  subnet3_id       = module.networks.subnet3_id
  router1_name     = var.router1_name
  router2_name     = var.router2_name
  router3_name     = var.router3_name
  subnet1_cidr     = var.subnet1_cidr
  subnet2_cidr     = var.subnet2_cidr
  subnet3_cidr     = var.subnet3_cidr
  router2_port_ip  = var.router2_port_ip
  router3_port_ip  = var.router3_port_ip
  router3_nexthop  = var.router3_nexthop

  depends_on = [module.networks]
}

module "security_groups" {
  source = "./modules/security-groups"

  sg_server1_name = var.sg_server1_name
  sg_server2_name = var.sg_server2_name
  sg_server3_name = var.sg_server3_name
  subnet1_cidr    = var.subnet1_cidr
  subnet2_cidr    = var.subnet2_cidr
}

module "servers" {
  source         = "./modules/servers"
  image          = var.image
  flavor         = var.flavor
  key_name       = var.key_name
  net1_id        = module.networks.net1_id
  net2_id        = module.networks.net2_id
  net3_id        = module.networks.net3_id
  sg_server1_id  = module.security_groups.sg_server1_id
  sg_server2_id  = module.security_groups.sg_server2_id
  sg_server3_id  = module.security_groups.sg_server3_id
  server1_name   = var.server1_name
  server2_name   = var.server2_name
  server3_name   = var.server3_name
  server1_metadata = var.server1_metadata
  server2_metadata = var.server2_metadata
  server3_metadata = var.server3_metadata

  depends_on = [module.routers, module.security_groups]
}

module "floating_ips" {
  source           = "./modules/floating-ips"
  external_network = var.external_network
  server1_port_id  = module.servers.server1_port_id

  depends_on = [module.servers]
}