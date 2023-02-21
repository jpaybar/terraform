# Crea Subred
# https://registry.terraform.io/providers/terraform-provider-openstack/openstack/latest/docs/resources/networking_subnet_v2

resource "openstack_networking_subnet_v2" "subred1" {
  network_id = "2c058666-4dda-48c3-8433-af2eb120d90f"
  cidr       = "10.10.10.0/26"
  name       = "subred_terraform"
  tenant_id  = "172ea88ae193456384de58b097052ee6"
}