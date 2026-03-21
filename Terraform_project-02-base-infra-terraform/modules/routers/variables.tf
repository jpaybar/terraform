variable "external_network" {
  description = "Nombre de la red externa"
  type        = string
}

variable "net1_id" {
  description = "ID de net1"
  type        = string
}

variable "net2_id" {
  description = "ID de net2"
  type        = string
}

variable "subnet1_id" {
  description = "ID de subnet1"
  type        = string
}

variable "subnet2_id" {
  description = "ID de subnet2"
  type        = string
}

variable "subnet3_id" {
  description = "ID de subnet3"
  type        = string
}

variable "router1_name" {
  description = "Nombre del router1"
  type        = string
  default     = "router1"
}

variable "router2_name" {
  description = "Nombre del router2"
  type        = string
  default     = "router2"
}

variable "router3_name" {
  description = "Nombre del router3"
  type        = string
  default     = "router3"
}

variable "subnet1_cidr" {
  description = "CIDR de subnet1"
  type        = string
}

variable "subnet2_cidr" {
  description = "CIDR de subnet2"
  type        = string
}

variable "subnet3_cidr" {
  description = "CIDR de subnet3"
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