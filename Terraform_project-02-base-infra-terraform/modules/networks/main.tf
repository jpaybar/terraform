terraform {
  required_providers {
    openstack = {
      source  = "terraform-provider-openstack/openstack"
      version = "~> 1.54"
    }
  }
}

resource "openstack_networking_network_v2" "net1" {
  name           = var.net1_name
  admin_state_up = true
}

resource "openstack_networking_network_v2" "net2" {
  name           = var.net2_name
  admin_state_up = true
}

resource "openstack_networking_network_v2" "net3" {
  name           = var.net3_name
  admin_state_up = true
}

resource "openstack_networking_subnet_v2" "subnet1" {
  name            = "${var.net1_name}-subnet"
  network_id      = openstack_networking_network_v2.net1.id
  cidr            = var.subnet1_cidr
  dns_nameservers = var.dns_nameservers
}

resource "openstack_networking_subnet_v2" "subnet2" {
  name            = "${var.net2_name}-subnet"
  network_id      = openstack_networking_network_v2.net2.id
  cidr            = var.subnet2_cidr
  dns_nameservers = var.dns_nameservers
}

resource "openstack_networking_subnet_v2" "subnet3" {
  name            = "${var.net3_name}-subnet"
  network_id      = openstack_networking_network_v2.net3.id
  cidr            = var.subnet3_cidr
  dns_nameservers = var.dns_nameservers
}

# ─── Rutas subnet1 ──────────────────────────────────────
resource "openstack_networking_subnet_route_v2" "subnet1_to_net2" {
  subnet_id        = openstack_networking_subnet_v2.subnet1.id
  destination_cidr = var.subnet2_cidr
  next_hop         = var.subnet1_nexthop
}

resource "openstack_networking_subnet_route_v2" "subnet1_to_net3" {
  subnet_id        = openstack_networking_subnet_v2.subnet1.id
  destination_cidr = var.subnet3_cidr
  next_hop         = var.subnet1_nexthop
}

# ─── Rutas subnet2 ──────────────────────────────────────
resource "openstack_networking_subnet_route_v2" "subnet2_to_net1" {
  subnet_id        = openstack_networking_subnet_v2.subnet2.id
  destination_cidr = var.subnet1_cidr
  next_hop         = var.subnet2_nexthop_to_net1
}

resource "openstack_networking_subnet_route_v2" "subnet2_to_net3" {
  subnet_id        = openstack_networking_subnet_v2.subnet2.id
  destination_cidr = var.subnet3_cidr
  next_hop         = var.subnet2_nexthop_to_net3
}

# ─── Rutas subnet3 ──────────────────────────────────────
resource "openstack_networking_subnet_route_v2" "subnet3_to_net1" {
  subnet_id        = openstack_networking_subnet_v2.subnet3.id
  destination_cidr = var.subnet1_cidr
  next_hop         = var.subnet3_nexthop
}

resource "openstack_networking_subnet_route_v2" "subnet3_to_net2" {
  subnet_id        = openstack_networking_subnet_v2.subnet3.id
  destination_cidr = var.subnet2_cidr
  next_hop         = var.subnet3_nexthop
}