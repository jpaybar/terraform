# ─── Servidor ───────────────────────────────────────────
image    = "ubuntu"
flavor   = "m1.tiny"
key_name = "my_host_key"

# ─── Red externa ────────────────────────────────────────
external_network = "external-network"

# ─── Redes ──────────────────────────────────────────────
net1_name = "net1"
net2_name = "net2"
net3_name = "net3"

# ─── CIDRs ──────────────────────────────────────────────
subnet1_cidr = "192.168.1.0/24"
subnet2_cidr = "192.168.2.0/24"
subnet3_cidr = "192.168.3.0/24"

# ─── DNS ────────────────────────────────────────────────
dns_nameservers = ["8.8.8.8"]

# ─── Next hops ──────────────────────────────────────────
subnet1_nexthop         = "192.168.1.254"
subnet2_nexthop_to_net1 = "192.168.2.1"
subnet2_nexthop_to_net3 = "192.168.2.254"
subnet3_nexthop         = "192.168.3.1"

# ─── Routers ────────────────────────────────────────────
router1_name    = "router1"
router2_name    = "router2"
router3_name    = "router3"
router2_port_ip = "192.168.1.254"
router3_port_ip = "192.168.2.254"
router3_nexthop = "192.168.2.1"

# ─── Security groups ────────────────────────────────────
sg_server1_name = "sg_server1"
sg_server2_name = "sg_server2"
sg_server3_name = "sg_server3"

# ─── Servidores ─────────────────────────────────────────
server1_name = "server1"
server2_name = "server2"
server3_name = "server3"

# ─── Metadatos Ansible ──────────────────────────────────
server1_metadata = {
  role        = "proxy"
  environment = "production"
}
server2_metadata = {
  role        = "webserver"
  application = "wordpress"
  environment = "production"
}
server3_metadata = {
  role        = "database"
  environment = "production"
}
