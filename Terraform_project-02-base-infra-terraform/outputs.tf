output "server1_floating_ip" {
  description = "Floating IP de server1 (Nginx)"
  value       = module.floating_ips.server1_floating_ip
}

output "server1_ip" {
  description = "IP fija de server1 (net1)"
  value       = module.servers.server1_ip
}

output "server2_ip" {
  description = "IP fija de server2 (net2)"
  value       = module.servers.server2_ip
}

output "server3_ip" {
  description = "IP fija de server3 (net3)"
  value       = module.servers.server3_ip
}
