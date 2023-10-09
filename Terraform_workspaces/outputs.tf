# Output definitions

output "database_name" {
    description = "Nombre de la bbdd."
    value       = var.database_name
}

output "user_name" {
    description = "Nombre de usuario."
    value  = var.user_name
}

output "user_passwd" {
    description = "Contraseña de usuario."
    value  = var.user_passwd
}

output "user_host" {
    description = "El host de origen del usuario."
    value  = var.user_host
}