variable "tf_keypair_name" {
    description = "Nombre del keypair a insertar en la Instancia."
    default  = "jpayan"
}

variable "tf_private_key" {
    description = "Path a la clave privada."
    default  = "~/.ssh/id_rsa"
}

variable "tf_public_key" {
    description = "Path a la clave pública."
    default  = "~/.ssh/id_rsa.pub"
}

variable "tf_network" {
    description = "Nombre de la Red."
    default  = "private"
}

variable "tf_instance" {
    description = "Nombre de la Instancia."
    default  = "Ubuntu_20.04_WordPress"
}

variable "tf_image_id" {
    description = "ID de la imágen."
    default  = "31356b48-ecef-4f3a-b31d-c82f8fe7ed16"
}

variable "tf_flavor_id" {
    description = "ID del sabor."
    default  = "d2"
}

variable "tf_floating_ip_pool" {
    description = "Pool para obtener las IP's Flotantes."
    default = "public"
}

variable "tf_security_groups" {
    description = "Lista de los Grupos de Seguridad a los que pertenecerá la Instancia."
    type = list
    default = ["default"]
}
