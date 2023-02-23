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

# Configure the OpenStack Provider (or source your RC Project file)
provider "openstack" {
  user_name         = "<OS_USERNAME>"
  tenant_name       = "<OS_PROJECT_NAME>"
  tenant_id         = "<OS_PROJECT_ID>"
  password          = "<OS_PASSWORD>"
  auth_url          = "<OS_AUTH_URL>"
  region            = "<OS_REGION_NAME>"
  user_domain_name  = "<OS_USER_DOMAIN_NAME>"
  project_domain_id = "<OS_PROJECT_DOMAIN_ID>"
}
