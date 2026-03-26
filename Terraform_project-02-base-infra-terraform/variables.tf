# ─── Servidor ───────────────────────────────────────────
variable "image" {
  description = "Imagen del servidor"
  type        = string
}

variable "flavor" {
  description = "Flavor del servidor"
  type        = string
}

variable "key_name" {
  description = "Nombre del par de claves SSH"
  type        = string
}

# ─── Red externa ────────────────────────────────────────
variable "external_network" {
  description = "Nombre de la red externa para routers y floating IPs"
  type        = string
}

# ─── Redes ──────────────────────────────────────────────
variable "net1_name" {
  description = "Nombre de la red 1"
  type        = string
}

variable "net2_name" {
  description = "Nombre de la red 2"
  type        = string
}

variable "net3_name" {
  description = "Nombre de la red 3"
  type        = string
}

# ─── CIDRs ──────────────────────────────────────────────
variable "subnet1_cidr" {
  description = "CIDR de la subnet1"
  type        = string
}

variable "subnet2_cidr" {
  description = "CIDR de la subnet2"
  type        = string
}

variable "subnet3_cidr" {
  description = "CIDR de la subnet3"
  type        = string
}

# ─── DNS ────────────────────────────────────────────────
variable "dns_nameservers" {
  description = "Lista de servidores DNS para las subnets"
  type        = list(string)
}

# ─── Next hops ──────────────────────────────────────────
variable "subnet1_nexthop" {
  description = "Next hop para las rutas salientes de subnet1"
  type        = string
}

variable "subnet2_nexthop_to_net1" {
  description = "Next hop de subnet2 hacia net1"
  type        = string
}

variable "subnet2_nexthop_to_net3" {
  description = "Next hop de subnet2 hacia net3"
  type        = string
}

variable "subnet3_nexthop" {
  description = "Next hop para las rutas salientes de subnet3"
  type        = string
}

# ─── Routers ────────────────────────────────────────────
variable "router1_name" {
  description = "Nombre del router1"
  type        = string
}

variable "router2_name" {
  description = "Nombre del router2"
  type        = string
}

variable "router3_name" {
  description = "Nombre del router3"
  type        = string
}

variable "router2_port_ip" {
  description = "IP fija del port de router2 en net1"
  type        = string
}

variable "router3_port_ip" {
  description = "IP fija del port de router3 en net2"
  type        = string
}

variable "router3_nexthop" {
  description = "Next hop para las rutas de router3"
  type        = string
}

# ─── Security groups ────────────────────────────────────
variable "sg_server1_name" {
  description = "Nombre del security group de server1"
  type        = string
}

variable "sg_server2_name" {
  description = "Nombre del security group de server2"
  type        = string
}

variable "sg_server3_name" {
  description = "Nombre del security group de server3"
  type        = string
}

# ─── Servidores ─────────────────────────────────────────
variable "server1_name" {
  description = "Nombre de server1"
  type        = string
}

variable "server2_name" {
  description = "Nombre de server2"
  type        = string
}

variable "server3_name" {
  description = "Nombre de server3"
  type        = string
}

# ─── Metadatos Ansible ──────────────────────────────────
variable "server1_metadata" {
  description = "Metadatos de server1 (grupos Ansible, rol, etc.)"
  type        = map(string)
  default     = {}
}

variable "server2_metadata" {
  description = "Metadatos de server2 (grupos Ansible, rol, etc.)"
  type        = map(string)
  default     = {}
}

variable "server3_metadata" {
  description = "Metadatos de server3 (grupos Ansible, rol, etc.)"
  type        = map(string)
  default     = {}
}