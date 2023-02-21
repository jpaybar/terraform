# Asociar un Volumen a una Instancia
# https://registry.terraform.io/providers/terraform-provider-openstack/openstack/latest/docs/resources/compute_volume_attach_v2

resource "openstack_compute_volume_attach_v2" "asociar_volumen" {
  instance_id = "57a7c5f4-6a41-4aeb-b564-5d329339afdb"
  volume_id  = "14f22def-cfd4-4063-9912-5779de9b2d1e"
}