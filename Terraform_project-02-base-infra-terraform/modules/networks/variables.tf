variable "net1_name" {
  description = "Nombre de la red 1"
  type        = string
  default     = "net1"
}

variable "net2_name" {
  description = "Nombre de la red 2"
  type        = string
  default     = "net2"
}

variable "net3_name" {
  description = "Nombre de la red 3"
  type        = string
  default     = "net3"
}

variable "subnet1_cidr" {
  description = "CIDR de la subnet1"
  type        = string
  default     = "192.168.1.0/24"
}

variable "subnet2_cidr" {
  description = "CIDR de la subnet2"
  type        = string
  default     = "192.168.2.0/24"
}

variable "subnet3_cidr" {
  description = "CIDR de la subnet3"
  type        = string
  default     = "192.168.3.0/24"
}

variable "dns_nameservers" {
  description = "Lista de servidores DNS para las subnets"
  type        = list(string)
  default     = ["8.8.8.8"]
}

variable "subnet1_nexthop" {
  description = "Next hop para las rutas salientes de subnet1"
  type        = string
  default     = "192.168.1.254"
}

variable "subnet2_nexthop_to_net1" {
  description = "Next hop de subnet2 hacia net1"
  type        = string
  default     = "192.168.2.1"
}

variable "subnet2_nexthop_to_net3" {
  description = "Next hop de subnet2 hacia net3"
  type        = string
  default     = "192.168.2.254"
}

variable "subnet3_nexthop" {
  description = "Next hop para las rutas salientes de subnet3"
  type        = string
  default     = "192.168.3.1"
}