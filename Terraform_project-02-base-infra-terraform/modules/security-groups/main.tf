terraform {
  required_providers {
    openstack = {
      source  = "terraform-provider-openstack/openstack"
      version = "~> 1.54"
    }
  }
}

# ─── SG SERVER1: Reverse proxy ───────────────────────────
resource "openstack_networking_secgroup_v2" "sg_server1" {
  name        = var.sg_server1_name
  description = "Reverse proxy - SSH, ICMP y HTTP publico"
}

resource "openstack_networking_secgroup_rule_v2" "sg_server1_ssh" {
  security_group_id = openstack_networking_secgroup_v2.sg_server1.id
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 22
  port_range_max    = 22
  remote_ip_prefix  = "0.0.0.0/0"
}

resource "openstack_networking_secgroup_rule_v2" "sg_server1_http" {
  security_group_id = openstack_networking_secgroup_v2.sg_server1.id
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 80
  port_range_max    = 80
  remote_ip_prefix  = "0.0.0.0/0"
}

resource "openstack_networking_secgroup_rule_v2" "sg_server1_icmp" {
  security_group_id = openstack_networking_secgroup_v2.sg_server1.id
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "icmp"
  remote_ip_prefix  = "0.0.0.0/0"
}

# ─── SG SERVER2: App server ───────────────────────────────
resource "openstack_networking_secgroup_v2" "sg_server2" {
  name        = var.sg_server2_name
  description = "App server - SSH e HTTP solo desde net1"
}

resource "openstack_networking_secgroup_rule_v2" "sg_server2_ssh" {
  security_group_id = openstack_networking_secgroup_v2.sg_server2.id
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 22
  port_range_max    = 22
  remote_ip_prefix  = var.subnet1_cidr
}

resource "openstack_networking_secgroup_rule_v2" "sg_server2_http" {
  security_group_id = openstack_networking_secgroup_v2.sg_server2.id
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 80
  port_range_max    = 80
  remote_ip_prefix  = var.subnet1_cidr
}

resource "openstack_networking_secgroup_rule_v2" "sg_server2_icmp" {
  security_group_id = openstack_networking_secgroup_v2.sg_server2.id
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "icmp"
  remote_ip_prefix  = var.subnet1_cidr
}

# ─── SG SERVER3: DB server ────────────────────────────────
resource "openstack_networking_secgroup_v2" "sg_server3" {
  name        = var.sg_server3_name
  description = "DB server - SSH y MySQL solo desde net2"
}

resource "openstack_networking_secgroup_rule_v2" "sg_server3_ssh" {
  security_group_id = openstack_networking_secgroup_v2.sg_server3.id
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 22
  port_range_max    = 22
  remote_ip_prefix  = var.subnet2_cidr
}

resource "openstack_networking_secgroup_rule_v2" "sg_server3_mysql" {
  security_group_id = openstack_networking_secgroup_v2.sg_server3.id
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 3306
  port_range_max    = 3306
  remote_ip_prefix  = var.subnet2_cidr
}

resource "openstack_networking_secgroup_rule_v2" "sg_server3_icmp" {
  security_group_id = openstack_networking_secgroup_v2.sg_server3.id
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "icmp"
  remote_ip_prefix  = var.subnet2_cidr
}