output "server1_port_id" {
  value = openstack_networking_port_v2.server1_port.id
}

output "server1_ip" {
  value = openstack_compute_instance_v2.server1.access_ip_v4
}

output "server2_ip" {
  value = openstack_compute_instance_v2.server2.access_ip_v4
}

output "server3_ip" {
  value = openstack_compute_instance_v2.server3.access_ip_v4
}
