terraform {
  required_providers {
    openstack = {
      source  = "terraform-provider-openstack/openstack"
      version = "~> 1.54"
    }
  }
}

data "openstack_networking_network_v2" "external" {
  name = var.external_network
}

resource "openstack_networking_floatingip_v2" "fip_server1" {
  pool = data.openstack_networking_network_v2.external.name
  # address = var.floating_ip   # IP dinámica — comentado
}

resource "openstack_networking_floatingip_associate_v2" "fip_assoc_server1" {
  floating_ip = openstack_networking_floatingip_v2.fip_server1.address
  port_id     = var.server1_port_id
}