# terraform destroy -var-file infra.tfvars -target='mysql_user.user["1"]'

#Declaramos una "lista de objetos/mapas" local.
locals {
  users = [
    {
      tls_option = ""
      user = "user01"
      plaintext_password = "user01"
      host = ""
    },
    {
      tls_option = ""
      user = "user02"
      plaintext_password = "user02"
      host = ""
    },
    {
      tls_option = ""
      user = "user03"
      plaintext_password = "user03"
      host = ""
    },
    {
      tls_option = ""
      user = "user04"
      plaintext_password = "user04"
      host = ""
    },
  ]

  group_id = ""
}

# locals {
#   group_id = ""
# }



# # 
# resource "null_resource" "condition_checker" {
#   count = "${var.users[*].user == 4 ? 0 : 1}"
#   #user = var.test == true ? "dev" : "prod"
#   provisioner "local-exec" {
#     command = "echo Hello World"
#   }
# }

# Crear usuario
resource "mysql_user" "user" {
  #for_each = {for i in local.users : i.user => i}
  for_each = { for i, user in var.users : i => user}
  #for_each = { for i, user in local.users : i => user}
  tls_option = each.value.tls_option
  user     = "${each.value.user}${var.group_id}"  # Creamos los usuarios
  #user     = "${each.value.user}${local.group_id[0]}" 
  #user     = each.value.user  
  plaintext_password = each.value.plaintext_password # Constraseñas 
  host     = each.value.host  # El host de origen del usuario. El valor predeterminado es "localhost"
}

