# Variable definitions

variable "database_name" {
    description = "Nombre de la bbdd."
    type = string
    default  = ""
}

variable "user_name" {
    description = "Contraseña de usuario."
    type = string
    default  = ""
}

variable "user_passwd" {
    description = "Contraseña de usuario."
    type = string
    default  = ""
}

variable "user_host" {
    description = "El host de origen del usuario."
    type = string
    default  = ""
}