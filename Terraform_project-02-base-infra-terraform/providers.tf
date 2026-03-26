terraform {
  required_providers {
    openstack = {
      source  = "terraform-provider-openstack/openstack"
      version = "~> 1.54"
    }
  }
}

provider "openstack" {
  cloud       = "openstack"  # apunta al nombre definido en ~/.config/openstack/clouds.yaml
  use_octavia = true
}