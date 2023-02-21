# Crear Regla SSH de entrada para toda la red
# https://registry.terraform.io/providers/terraform-provider-openstack/openstack/latest/docs/resources/networking_secgroup_rule_v2

resource "openstack_networking_secgroup_rule_v2" "ssh_rule" {
  direction         = "ingress" # Regla de Entrada
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 22
  port_range_max    = 22
  remote_ip_prefix  = "0.0.0.0/0" # Para toda la red
  security_group_id = "960eef7e-267f-4afd-90b0-a3a72489e0b2"
}