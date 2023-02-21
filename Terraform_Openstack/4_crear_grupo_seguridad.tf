# Crear Grupo de Seguridad
# https://registry.terraform.io/providers/terraform-provider-openstack/openstack/latest/docs/resources/networking_secgroup_v2

resource "openstack_networking_secgroup_v2" "grupo_seguridad" {
  name        = "grupo_seguridad_1"
  description = "Cread desde Terraform"
  tenant_id   = "172ea88ae193456384de58b097052ee6"
}