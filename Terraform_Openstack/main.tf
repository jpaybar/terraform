# https://registry.terraform.io/providers/terraform-provider-openstack/openstack/1.48.0/docs#example-usage

# Define required providers
terraform {
required_version = ">= 0.14.0"
  required_providers {
    openstack = {
      source  = "terraform-provider-openstack/openstack"
      version = "~> 1.48.0"
    }
  }
}

# Configure the OpenStack Provider
provider "openstack" {
  user_name   = "admin"
  tenant_name = "admin"
  password    = "openstack"
  auth_url    = "http://192.168.56.15/identity"
  region      = "RegionOne"
}