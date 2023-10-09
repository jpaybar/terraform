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
  endpoint = "192.168.227.56" # La dirección del servidor MySQL, "hostname:port"
  username = "root" # Nombre de usuario a usar para autenticarse con el servidor.
  password = "root"
}