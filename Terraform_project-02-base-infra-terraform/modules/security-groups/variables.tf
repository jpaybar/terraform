variable "sg_server1_name" {
  description = "Nombre del security group de server1"
  type        = string
  default     = "sg_server1"
}

variable "sg_server2_name" {
  description = "Nombre del security group de server2"
  type        = string
  default     = "sg_server2"
}

variable "sg_server3_name" {
  description = "Nombre del security group de server3"
  type        = string
  default     = "sg_server3"
}

variable "subnet1_cidr" {
  description = "CIDR de subnet1, usado para reglas de server2"
  type        = string
}

variable "subnet2_cidr" {
  description = "CIDR de subnet2, usado para reglas de server3"
  type        = string
}