terraform {
  required_providers {
    openstack = {
      source  = "terraform-provider-openstack/openstack"
      version = "~> 1.54"
    }
  }
}

# ─── PORTS ───────────────────────────────────────────────
resource "openstack_networking_port_v2" "server1_port" {
  name               = "${var.server1_name}-port"
  network_id         = var.net1_id
  admin_state_up     = true
  security_group_ids = [var.sg_server1_id]
}

resource "openstack_networking_port_v2" "server2_port" {
  name               = "${var.server2_name}-port"
  network_id         = var.net2_id
  admin_state_up     = true
  security_group_ids = [var.sg_server2_id]
}

resource "openstack_networking_port_v2" "server3_port" {
  name               = "${var.server3_name}-port"
  network_id         = var.net3_id
  admin_state_up     = true
  security_group_ids = [var.sg_server3_id]
}

# ─── VMs ─────────────────────────────────────────────────
resource "openstack_compute_instance_v2" "server1" {
  name        = var.server1_name
  image_name  = var.image
  flavor_name = var.flavor
  key_pair    = var.key_name

  network {
    port = openstack_networking_port_v2.server1_port.id
  }
}

resource "openstack_compute_instance_v2" "server2" {
  name        = var.server2_name
  image_name  = var.image
  flavor_name = var.flavor
  key_pair    = var.key_name

  network {
    port = openstack_networking_port_v2.server2_port.id
  }
}

resource "openstack_compute_instance_v2" "server3" {
  name        = var.server3_name
  image_name  = var.image
  flavor_name = var.flavor
  key_pair    = var.key_name

  network {
    port = openstack_networking_port_v2.server3_port.id
  }
}