### terraform workspace new "workspace01"
### terraform workspace list
### terraform plan -var-file workspace01.tfvars
### terraform plan -var-file workspace01.tfvars -target "resource.resource_name"

# Crear base de datos
resource "mysql_database" "database" {
  name = var.database_name  #Creamos la BD
}

# Crear usuario
resource "mysql_user" "user" {
  user     = var.user_name  # Creamos el usuario
  host     = var.user_host  # El host de origen del usuario. El valor predeterminado es "localhost"
  plaintext_password = var.user_passwd    # Constraseña del usuario
}

