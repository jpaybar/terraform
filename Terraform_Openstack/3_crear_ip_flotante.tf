# Crea IP Flotante
# https://registry.terraform.io/providers/terraform-provider-openstack/openstack/latest/docs/resources/compute_floatingip_v2

resource "openstack_compute_floatingip_v2" "ip" {
  pool = "public"
}