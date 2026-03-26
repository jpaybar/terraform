variable "image" {
  description = "Imagen a usar para las VMs"
  type        = string
}

variable "flavor" {
  description = "Flavor de las VMs"
  type        = string
}

variable "key_name" {
  description = "Nombre del keypair"
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

variable "net3_id" {
  description = "ID de net3"
  type        = string
}

variable "sg_server1_id" {
  description = "ID del security group de server1"
  type        = string
}

variable "sg_server2_id" {
  description = "ID del security group de server2"
  type        = string
}

variable "sg_server3_id" {
  description = "ID del security group de server3"
  type        = string
}

variable "server1_name" {
  description = "Nombre de server1"
  type        = string
  default     = "server1"
}

variable "server2_name" {
  description = "Nombre de server2"
  type        = string
  default     = "server2"
}

variable "server3_name" {
  description = "Nombre de server3"
  type        = string
  default     = "server3"
}

variable "server1_metadata" {
  description = "Metadatos de server1 para inventario dinámico de Ansible"
  type        = map(string)
  default     = {}
}

variable "server2_metadata" {
  description = "Metadatos de server2 para inventario dinámico de Ansible"
  type        = map(string)
  default     = {}
}

variable "server3_metadata" {
  description = "Metadatos de server3 para inventario dinámico de Ansible"
  type        = map(string)
  default     = {}
} 