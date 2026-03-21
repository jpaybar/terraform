terraform {
  required_providers {
    openstack = {
      source  = "terraform-provider-openstack/openstack"
      version = "~> 1.54"
    }
  }
}

# ─── OBTENER RED EXTERNA ─────────────────────────────────
data "openstack_networking_network_v2" "external" {
  name = var.external_network
}

# ─── ROUTERS ─────────────────────────────────────────────
resource "openstack_networking_router_v2" "router1" {
  name                = var.router1_name
  admin_state_up      = true
  external_network_id = data.openstack_networking_network_v2.external.id
}

resource "openstack_networking_router_v2" "router2" {
  name           = var.router2_name
  admin_state_up = true
}

resource "openstack_networking_router_v2" "router3" {
  name           = var.router3_name
  admin_state_up = true
}

# ─── INTERFACES ROUTER1 ──────────────────────────────────
resource "openstack_networking_router_interface_v2" "r1_subnet1" {
  router_id = openstack_networking_router_v2.router1.id
  subnet_id = var.subnet1_id
}

# ─── PORT CON IP FIJA PARA ROUTER2 EN NET1 ───────────────
resource "openstack_networking_port_v2" "router2_port_net1" {
  name       = "${var.router2_name}-port-net1"
  network_id = var.net1_id

  fixed_ip {
    subnet_id  = var.subnet1_id
    ip_address = var.router2_port_ip
  }
}

resource "openstack_networking_router_interface_v2" "r2_net1" {
  router_id = openstack_networking_router_v2.router2.id
  port_id   = openstack_networking_port_v2.router2_port_net1.id
}

resource "openstack_networking_router_interface_v2" "r2_subnet2" {
  router_id = openstack_networking_router_v2.router2.id
  subnet_id = var.subnet2_id
}

# ─── PORT CON IP FIJA PARA ROUTER3 EN NET2 ───────────────
resource "openstack_networking_port_v2" "router3_port_net2" {
  name       = "${var.router3_name}-port-net2"
  network_id = var.net2_id

  fixed_ip {
    subnet_id  = var.subnet2_id
    ip_address = var.router3_port_ip
  }
}

resource "openstack_networking_router_interface_v2" "r3_net2" {
  router_id = openstack_networking_router_v2.router3.id
  port_id   = openstack_networking_port_v2.router3_port_net2.id
}

resource "openstack_networking_router_interface_v2" "r3_subnet3" {
  router_id = openstack_networking_router_v2.router3.id
  subnet_id = var.subnet3_id
}

# ─── RUTAS ESTÁTICAS ─────────────────────────────────────
resource "openstack_networking_router_route_v2" "router1_to_net2" {
  router_id        = openstack_networking_router_v2.router1.id
  destination_cidr = var.subnet2_cidr
  next_hop         = var.router2_port_ip

  depends_on = [
    openstack_networking_router_interface_v2.r1_subnet1,
    openstack_networking_router_interface_v2.r2_net1
  ]
}

resource "openstack_networking_router_route_v2" "router1_to_net3" {
  router_id        = openstack_networking_router_v2.router1.id
  destination_cidr = var.subnet3_cidr
  next_hop         = var.router2_port_ip

  depends_on = [
    openstack_networking_router_interface_v2.r1_subnet1,
    openstack_networking_router_interface_v2.r2_net1
  ]
}

resource "openstack_networking_router_route_v2" "router2_to_net3" {
  router_id        = openstack_networking_router_v2.router2.id
  destination_cidr = var.subnet3_cidr
  next_hop         = var.router3_port_ip

  depends_on = [
    openstack_networking_router_interface_v2.r2_subnet2,
    openstack_networking_router_interface_v2.r3_net2
  ]
}

resource "openstack_networking_router_route_v2" "router3_to_net1" {
  router_id        = openstack_networking_router_v2.router3.id
  destination_cidr = var.subnet1_cidr
  next_hop         = var.router3_nexthop

  depends_on = [
    openstack_networking_router_interface_v2.r3_net2,
    openstack_networking_router_interface_v2.r3_subnet3
  ]
}

resource "openstack_networking_router_route_v2" "router3_to_net2" {
  router_id        = openstack_networking_router_v2.router3.id
  destination_cidr = var.subnet2_cidr
  next_hop         = var.router3_nexthop

  depends_on = [
    openstack_networking_router_interface_v2.r3_net2,
    openstack_networking_router_interface_v2.r3_subnet3
  ]
}