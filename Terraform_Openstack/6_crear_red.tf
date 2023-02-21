# Crear Red
# https://registry.terraform.io/providers/terraform-provider-openstack/openstack/latest/docs/resources/networking_network_v2

resource "openstack_networking_network_v2" "red1" {
  name           = "Red creada con Terraform"
  admin_state_up = "true"
  tenant_id      = "172ea88ae193456384de58b097052ee6"
}