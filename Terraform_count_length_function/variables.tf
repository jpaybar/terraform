# Variable definitions

variable "database_name" {
    description = "Nombre de la bbdd."
    type = list(string)
    default = []
}

variable "user_name" {
    description = "Nombres de usuario."
    type = list(string)
    default = []
}

variable "user_passwd" {
    description = "Contraseñas de usuario."
    type = list(string)
    default = []
}

variable "user_host" {
    description = "El host de origen de los usuario."
    type = string
    default  = ""
}