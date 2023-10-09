# Crear base de datos
resource "mysql_database" "database" {
  count = length(var.database_name)
  name = var.database_name[count.index]  #Creamos la BD
}

# Crear usuario
resource "mysql_user" "user" {
  count = length(var.user_name)
  user     = var.user_name[count.index]  # Creamos el usuario
  plaintext_password = var.user_passwd[count.index] # Constraseña del usuario
  host     = var.user_host  # El host de origen del usuario. El valor predeterminado es "localhost"
}

