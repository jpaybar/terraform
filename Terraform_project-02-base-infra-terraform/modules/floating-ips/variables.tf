variable "external_network" {
  description = "Nombre de la red externa"
  type        = string
}

variable "server1_port_id" {
  description = "ID del port de server1"
  type        = string
}

# ─── IPs fijas ──────────────────────────────────────────

variable "floating_ip" {
  description = "IP flotante fija para server1 (vacío = dinámica)"
  type        = string
  default     = ""
}