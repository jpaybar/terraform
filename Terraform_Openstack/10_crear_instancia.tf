# Crear una Instancia
# https://registry.terraform.io/providers/terraform-provider-openstack/openstack/latest/docs/resources/compute_instance_v2

resource "openstack_compute_instance_v2" "instancia" {
  name            = "instancia_ubuntu2004"
  image_id        = "89b6fd42-7215-4d6f-b851-bfcb25527289"
  flavor_id       = "d2"
  key_pair        = "jpayan"
  security_groups = ["grupo_seguridad_1"]
  
  network {
    name = "Red creada con Terraform"
  }

  metadata = {
    "Instancia creada con" = "Terraform"
  }
}

# Asocia IP Flotante a una Instancia
# https://registry.terraform.io/providers/terraform-provider-openstack/openstack/latest/docs/resources/compute_floatingip_associate_v2

resource "openstack_compute_floatingip_associate_v2" "floating_ip" {
  floating_ip = "${openstack_compute_floatingip_v2.ip.address}"
  instance_id = "${openstack_compute_instance_v2.instancia.id}"
}