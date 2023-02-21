# Crear Interfaz en un Router
# https://registry.terraform.io/providers/terraform-provider-openstack/openstack/latest/docs/resources/networking_router_interface_v2

resource "openstack_networking_router_interface_v2" "interfaz_router1" {
  router_id = "bfaa53f9-fda6-459c-abfc-3a4396aa74ab"
  subnet_id = "91a9207c-432e-4b5a-abef-25fe87780f22"
}