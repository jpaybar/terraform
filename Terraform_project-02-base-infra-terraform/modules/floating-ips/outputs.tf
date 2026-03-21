output "server1_floating_ip" {
  description = "Floating IP de server1 (Nginx)"
  value       = openstack_networking_floatingip_v2.fip_server1.address
}
