# Output definitions

output "group_id" {
    description = "Grupo del usuario."
    value       = var.group_id 
}

output "user" {
    description = "Nombre de usuario."
    value       = var.users[*].user
}

output "host" {
    description = "Host de origen."
    value       = var.users[*].host
}

