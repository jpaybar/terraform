# Crear Volumen
# https://registry.terraform.io/providers/terraform-provider-openstack/openstack/latest/docs/resources/blockstorage_volume_v2

resource "openstack_blockstorage_volume_v2" "volumen" {
  name        = "volumen_1"
  description = "Volumen de Pruebas de 1Gb"
  size        = 1
  volume_type = "lvmdriver-1"
  availability_zone = "nova"
}