resource "openstack_compute_instance_v2" "Instance" {
  name = var.tf_instance
  flavor_id = var.tf_flavor_id
  image_id = var.tf_image_id
  key_pair = var.tf_keypair_name
  security_groups = var.tf_security_groups
  network {
    name = var.tf_network
  }
  metadata = {
    "Instance created by" = "Terraform"
  }
  user_data = file("cloud-init.sh")
}

resource "openstack_compute_keypair_v2" "keypair" {
  name       = var.tf_keypair_name
  public_key = file(var.tf_public_key)
}

resource "openstack_networking_floatingip_v2" "fip" {
  pool = var.tf_floating_ip_pool
}

resource "openstack_compute_floatingip_associate_v2" "fip" {
  floating_ip = openstack_networking_floatingip_v2.fip.address
  instance_id = openstack_compute_instance_v2.Instance.id
  
  # Ejecuta comandos en la propia instancia 
  # https://developer.hashicorp.com/terraform/language/resources/provisioners/remote-exec
  provisioner "remote-exec" {
    script = "setup_proxy.sh"

  connection {
    host        = "${openstack_networking_floatingip_v2.fip.address}"
    type        = "ssh"
    user        = "ubuntu"
    agent       = false
    private_key = file(var.tf_private_key)
    }
  }

  # Ejecuta el playbook de "Ansible" que aprovisionará la instancia con "WordPress"
  # https://developer.hashicorp.com/terraform/language/resources/provisioners/local-exec
  provisioner "local-exec" {
    environment = {
      PUBLIC_IP                 = "${openstack_networking_floatingip_v2.fip.address}"
      PRIVATE_IP                = "${openstack_compute_instance_v2.Instance.access_ip_v4}" 
      ANSIBLE_HOST_KEY_CHECKING = "False"
    }

    working_dir = "wordpress/"
    command     = "ansible-playbook -u ubuntu --private-key=${var.tf_private_key} -i ${openstack_networking_floatingip_v2.fip.address}, playbook.yml"
  }
}

## Mostramos los valores de las IP's de la instancia al ejecutar "terraform apply"
## Podemos volver a verlos ejecutando "terraform output"

output "instance_ip" {
    value = openstack_compute_instance_v2.Instance.access_ip_v4
}

output "float_ip" {
    value = openstack_networking_floatingip_v2.fip.address
}
