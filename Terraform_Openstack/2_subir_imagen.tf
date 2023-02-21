# Subir imagen Ubuntu 20.04
# https://registry.terraform.io/providers/terraform-provider-openstack/openstack/latest/docs/resources/images_image_v2

resource "openstack_images_image_v2" "imagen_ubuntu2004" {
  name   = "Ubuntu 20.04 Focal Fossa"
  local_file_path = "/home/vagrant/terraform_openstack/focal-server-cloudimg-amd64.img"
  container_format = "bare"
  disk_format = "qcow2"
}