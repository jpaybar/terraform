terraform { # https://developer.hashicorp.com/terraform/language/providers/requirements#requiring-providers
  required_providers { # Terraform v0.13 y versiones posteriores
    mysql = {
      source  = "winebarrel/mysql"
      version = "~> 1.10.2"
    }
  }
  required_version = ">= 0.13"
}

# Conexión al servidor MySQL
provider "mysql" {
  endpoint = "172.17.0.1" # La dirección del servidor MySQL, "hostname:port"
  username = "root" # Nombre de usuario a usar para autenticarse con el servidor.
  password = "password"
}

# Crear base de datos
resource "mysql_database" "db_prueba" {
  name = "db_prueba"  #Creamos la BD
}

# Crear usuario
resource "mysql_user" "jpayan" {
  user     = "jpayan"  # Creamos el usuario
  host     = "172.17.0.1"  # El host de origen del usuario. El valor predeterminado es "localhost"
  plaintext_password = "jpayan"    # Constraseña del usuario
}

# Crear otro usuario
resource "mysql_user" "usuario1" {
  user     = "usuario1"  # Creamos otro usuario
  host     = "172.17.0.1"  
  plaintext_password = "usuario1"    
}

