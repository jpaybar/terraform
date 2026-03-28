resource "openstack_compute_flavor_v2" "custom" {
  name      = "m1.custom"
  ram       = 1024
  vcpus     = 1
  disk      = 10
  is_public = true
}
