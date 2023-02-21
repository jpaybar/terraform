# Crea Router Conectado a la Red Publica
# https://registry.terraform.io/providers/terraform-provider-openstack/openstack/latest/docs/resources/networking_router_v2

resource "openstack_networking_router_v2" "router1" {
  name             = "router1"
  external_network_id = "2526aa80-f92d-421e-a157-72e2812de673" # Id de la Red Publica
  tenant_id        = "172ea88ae193456384de58b097052ee6"
}