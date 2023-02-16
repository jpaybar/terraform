# TERRAFORM:

# Introducción, instalación y construcción de una infraestructura de pruebas con el proveedor MySQL sobre un contenedor Docker

###### By Juan Manuel Payán / jpaybar

st4rt.fr0m.scr4tch@gmail.com

## INTRODUCCIÓN

### ¿Qué es Terraform?

`Terraform` es una herramienta de código abierto de tipo "Infraestructura como código", creada por `HashiCorp`.

Funciona de forma declarativa por lo que permite utilizar un `lenguaje de configuración` de alto nivel llamado `HCL` (HashiCorp Configuration Language) para describir la infraestructura, aunque también acepta ficheros `JSON`. La creación y gestión de las `infraestructuras pueden ser tanto en local como cloud`. Con esta herramienta declaramos el "estado final" deseado, para ello, se elabora un plan (`terraform plan`) para alcanzar ese estado final y posteriormente se aplican dichos cambios en la infraestructura (`terraform apply`).

### ¿Cuál es la diferencia entre `Terraform` y otras herramientas como `Ansible`, `Chef` o `Puppet`?

`Ansible` es un herramienta de `gestión de la configuración` y `Terraform` es una `herramienta de orquestación`. Ésta es la gran diferencia entre `Terraform` y `Ansible`. Aunque algunas de sus características son comunes.

`Ansible` se usa para agregar, actualizar, eliminar y administrar la configuración de la infraestructura de TI, mientras que `Terraform` se usa para declarar componentes de infraestructura y organizarlos en múltiples proveedores, tanto en la nube como en local.

### ¿Cómo se estructuran los proyectos de `Terraform`?

La forma más básica, sería crear un fichero con extensión `.tf` si usamos el lenguaje `HCL` o `.tf.json` si usamos un fichero de configuración `JSON`. Dentro de este fichero, declaramos el proveedor, la versión, recursos a crear, etc...

Podemos tener otros ficheros, por ejemplo para declarar variables.

Una directiva importante dentro de nuestro fichero de configuración es el `proveedor`. Como hemos citado anteriormente, `Terraform` se utiliza para crear, administrar y actualizar recursos de infraestructura como máquinas físicas, máquinas virtuales, routers , contenedores, etc... en un proveedor. Un proveedor facilita que su API interaccione con `Terraform`. Los proveedores pueden ser `IaaS, PaaS y SaaS`:
La lista completa de proveedores se encuentra en la documentación oficial: https://www.terraform.io/docs/providers/index.html

##### **NOTA:**

**Desde `Terraform` > 0.13, se debe agregar un fragmento de código `required_providers` para cualquier proveedor no oficial (no oficial significa que no es propiedad de `HashiCorp` y no forma parte de su registro).
Busqueda de proveedores:**
[https://developer.hashicorp.com/terraform/language/providers#how-to-find-providers]()
[https://registry.terraform.io/browse/providers]()

### Inicialización del proyecto

Cada vez que se agrega un nuevo proveedor a la configuración, es necesario inicializar ese proveedor antes de usarlo. La inicialización descarga e instala el plugin del proveedor y lo prepara para su uso. Para llevar acabo dicha inicialización ejecutamos el comando `terraform init`. 
Los proveedores descargados por `terraform init` solo se instalan para el directorio de trabajo actual, cada directorio de trabajo puede tener sus propias versiones de proveedor instaladas.

##### **NOTA:**

**Podriamos decir que el comando `terraform init` sería algo similar a ejecutar `vagrant init`, otra de las herramientas de la compañia `HashiCorp`, que ya hemos citado con anterioridad en otras publicaciones.**

[[vagrant init - Command-Line Interface | Vagrant | HashiCorp Developer](https://developer.hashicorp.com/vagrant/docs/cli/init)](Vagrant)

### Comandos básicos para ejecutar un proyecto

- `terraform init:`

Escanea el código para determinar qué proveedores estámos utilizando y descargarlos. 

- `terraform plan:`

Nos permite ver lo que `Terraform` está a punto de hacer antes de aplicar los cambios.

- `terraform validate:`

Comprueba si la configuración es sintácticamente válida.

- `terraform apply:`

Aprovisionará los recursos especificados en los archivos `.tf`.

## INSTALACIÓN

https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli

### Desde repositorio para distribuciones Ubuntu/Debian

```bash
wget -O- https://apt.releases.hashicorp.com/gpg | gpg --dearmor | sudo tee /usr/share/keyrings/hashicorp-archive-keyring.gpg
```

```bash
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
```

```bash
sudo apt update && sudo apt install terraform
```

### Desde binario a /usr/local/bin

```bash
sudo apt-get update
```

```bash
sudo apt-get install unzip -y
```

```bash
version=`curl -s https://api.github.com/repos/hashicorp/terraform/releases/latest | grep tag_name | cut -d: -f2 | tr -d \"\,\v | awk '{$1=$1};1'`
```

```bash
wget https://releases.hashicorp.com/terraform/${version}/terraform_${version}_linux_amd64.zip
```

```bash
unzip terraform_${version}_linux_amd64.zip
```

```bash
sudo chown root:root terraform
```

```bash
sudo mv terraform /usr/local/bin/
```

```bash
terraform version
```

### Desde binario a /opt

Ejecutamos todos los pasos anteriores hasta el comando `sudo chown root:root terraform`

```bash
sudo mkdir /opt/terraform
```

```bash
sudo mv terraform /opt/terraform
```

```bash
echo PATH="$PATH:/opt/terraform" >>  ~/.bashrc
```

```bash
source .bashrc
```

```bash
terraform version
```

## Creación y actualización de Bases de Datos y usuarios con el proveedor MySQL

Como ejemplo, en este tutorial crearemos una base de datos de `MySQL` llamada `db_prueba` y un usuario `jpayan`. Posteriormente actualizaremos el código de nuestro fichero de configuración para añadir un segundo usuario llamado `usuario1`.

Para realizar todas estas pruebas levantaremos un contenedor `Docker` con la imágen de `MySQL` y haremos todos los cambios sobre dicho servidor.

**NOTA:**

**Este proveedor se puede utilizar junto con otros recursos que crean servidores `MySQL` para el caso de instancias en la nube como `AWS`. Por ejemplo, la directiva `aws_db_instance` es capaz de crear servidores `MySQL` en el servicio RDS de Amazon.**

**Aquí un ejemplo de código:**

```hcl
resource "aws_db_instance" "default" {
 engine = "mysql"
 engine_version = "5.6.17"
 instance_class = "db.t1.micro"
 name = "initial_db"
 username = "rootuser"
 password = "rootpasswd"

}
provider "mysql" {
 endpoint = "${aws_db_instance.default.endpoint}"
 username = "${aws_db_instance.default.username}"
 password = "${aws_db_instance.default.password}"
}
```

También comentaremos las directivas de nuestro fichero de configuración que se llamará `mysql-example.tf` y otras posibilidades que nos ofrece el proveedor `MySQL` como son; dar permisos (GRANT), crear Roles, tablas, etc...

### Contenedor `Docker` con la imágen de `MySQL`

Levantamos nuestro contenedor:

```bash
docker run --name mysql-server -d -p 3306:3306 -v /home/vagrant/mysql_docker:/var/lib/mysql -e MYSQL_ROOT_PASSWORD=password mysql:latest
```

```bash
vagrant@masterVM:~$ docker container ps
CONTAINER ID   IMAGE          COMMAND                  CREATED        STATUS        PORTS                                                  NAMES
71f53066da1d   mysql:latest   "docker-entrypoint.s…"   22 hours ago   Up 22 hours   0.0.0.0:3306->3306/tcp, :::3306->3306/tcp, 33060/tcp   mysql-server
```

Confirmamos que nuestro servidor `MySQL` solo tiene las Bases de Datos de una instalación limpia

![original_mysql_container.PNG](https://github.com/jpaybar/Terraform/blob/main/Terraform_introduccion_mysql_provider/_images/original_mysql_container.PNG)

### Archivo de configuración

El arhivo de configuración define el proveedor, en este caso `MySQL` y contiene los datos para poder conectar al motor de base de datos. También se definen los recursos a crear que serían una base de datos llamada `db_prueba` y un usuario `jpayan` con igual contraseña.

```hcl
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
```

Como se puede observar el fichero de configuración es bastante intuitivo y hemos comentado cada directiva con su función correspondiente.

El proveedor `MySQL` ya no está soportado nativamente desde el espacio de nombres de HashiCorp, por lo que usaremos uno de la comunidad, en este caso `winebarrel/mysql`. A continuación el enlace a la busqueda de proveedores:

https://developer.hashicorp.com/terraform/language/providers#how-to-find-providers

Bien, una vez tenemos definido nuestro fichero de configuración `HCL` de `Terraform`, tenemos que inicializar el proyecto. Desde el directorio del proyecto, ejecutaremos el comando `terraform init`. Cada vez que se agrega un nuevo proveedor a la configuración, es necesario inicializar ese proveedor antes de usarlo. La inicialización descarga e instala el plugin del proveedor y lo prepara para su uso. 

Ejecutamos `terraform init` y obtendremos una salida similar a la siguiente:

```bash
Initializing the backend...

Initializing provider plugins...
- Finding latest version winebarrel/mysqlsql...
- Installing winebarrel/mysqlysql v1.2.1...
```

El siguiente comando que ejecutaremos será `terraform plan`, nos permite ver el estado deseado al que quermos llegar antes de ser llevado a cabo. Sería algo similar al flag `-C` o `--check` cuando ejecutamos `ansible-playbook`.

![terraform_plan.PNG](https://github.com/jpaybar/Terraform/blob/main/Terraform_introduccion_mysql_provider/_images/terraform_plan.PNG)

Confirmamos que es la planificación deseada y ejecutamos `terraform apply`:

![terraform_apply.PNG]([https://github.com/jpaybar/Terraform/tree/main/Terraform_introduccion_mysql_provider/_images/terraform_apply.PNG](https://github.com/jpaybar/Terraform/blob/main/Terraform_introduccion_mysql_provider/_images/terraform_apply.PNG))

nos pedirá que confirmemos que queremos realizar los cambios escribiendo por la terminal `yes` y nos muestra los cambios realizados.

Vamos a confirmar que se han creado tanto la base de datos `db_prueba` como el usuario `jpayan`, para ello nos conectaremos a nuestro contenedor de `MySQL` en modo interactivo y con la terminal `bash` y lo verificamos desde el cliente `mysql`. Para ello ejecutamos el siguiente comando:

```bash
docker exec -it mysql-server bash
```

Comprobamos que se ha creado correctamente la base de datos `db_prueba`:

![mysql_container_1cambio_db.PNG](https://github.com/jpaybar/Terraform/blob/main/Terraform_introduccion_mysql_provider/_images/mysql_container_1cambio_db.PNG)

Y que también se ha creado el usuario `jpayan`:

![mysql_container_1cambio_usuario.PNG](https://github.com/jpaybar/Terraform/blob/main/Terraform_introduccion_mysql_provider/_images/mysql_container_1cambio_usuario.PNG)

Como dijimos al inicio, creariamos un segundo usuario llamado `usuario1` para modificar la infraestructura en el servidor `MySQL` y aplicar los nuevos cambios (también podría ser algo muy funcional como cambiar las contraseñas del usuario). Para ello editamos nuestro fichero de configuración y añadimos el nuevo recurso de usuario y quedaría de la siguiente forma:

```hcl
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
```

Volvemos a ejecutar `terraform plan` y nos mostrará el estado nuevo a alcanzar con los cambio y añadidos:

![mysql_container_2cambio_other_user.PNG](https://github.com/jpaybar/Terraform/blob/main/Terraform_introduccion_mysql_provider/_images/mysql_container_2cambio_other_user.PNG)

Ejecutamos de nuevo `terraform apply` y verificamos que se ha creado el nuevo usuario `usuario1`

```sql
mysql> select user,host from user;
+------------------+------------+
| user             | host       |
+------------------+------------+
| root             | %          |
| jpayan           | 172.17.0.1 |
| usuario1         | 172.17.0.1 |
| mysql.infoschema | localhost  |
| mysql.session    | localhost  |
| mysql.sys        | localhost  |
| root             | localhost  |
+------------------+------------+
7 rows in set (0.00 sec)
```

## Otros recursos del proveedor `MySQL`

### mysql_grant

El recurso `mysql_grant` crea y administra los privilegios otorgados a un usuario en un servidor `MySQL`.
Concesión de privilegios `SELECT` y `UPDATE` al usuario `jpayan`:

```hcl
resource "mysql_user" "jpayan" {
 user = "jpayan"
 host = "172.17.0.1"
 plaintext_password = "jpayan"
}
resource "mysql_grant" "jpayan" {
 user = "${mysql_user.jpayan.user}"
 host = "${mysql_user.jpayan.host}"
 database = "db_prueba"
 privileges = ["SELECT", "UPDATE"]
}
```

### mysql_role

##### **NOTA:**

**`MySQL` introdujo la función `Rol` en la versión 8. `No funcionan en MySQL 5 y versiones anteriores.`**

Concesión de privilegios `SELECT` y `UPDATE` al `Rol` llamado `developer`:

```hcl
resource "mysql_role" "developer" {
 name = "developer"
}
resource "mysql_grant" "developer" {
 role = "${mysql_role.developer.name}"
 database = "db_prueba"
 privileges = ["SELECT", "UPDATE"]
}
```

Agregar al usuario `jpayan` al Rol `developer`:

```hcl
resource "mysql_user" "jpayan" {
 user = "jpayan"
 host = "172.17.0.1"
 plaintext_password = "jpayan"
}
resource "mysql_role" "developer" {
 name = "developer"
}
resource "mysql_grant" "developer" {
 user = "${mysql_user.jpayan.user}"
 host = "${mysql_user.jpayan.host}"
 database = "db_prueba"
 roles = ["${mysql_role.developer.name}"]
}
```

Se admiten los siguientes argumentos:

- `user:` (Opcional) El nombre del usuario. Conflictos con el rol.

- `host:` (opcional) el host de origen del usuario. El valor predeterminado es "localhost". Conflictos con el rol.

- `role:` (opcional) el rol al que se otorgan privilegios. Conflictos con el usuario y el host.

- `database:` (Obligatorio) La base de datos para otorgar privilegios.

- `table:` (Opcional) En qué tabla otorgar privilegios. El valor predeterminado es * , que son todas las tablas.

- `privileges:` (Opcional) Una lista de privilegios para otorgar al usuario. Consulte una lista de privilegios (como aquí
  (https://dev.mysql.com/doc/refman/5.5/en/grant.html)) para conocer los privilegios aplicables.

- `roles:` (opcional) una lista de roles para otorgar al usuario. Conflictos con privilegios.

- `tls_option:` (opcional) una opción TLS para la instrucción GRANT. El valor tiene el sufijo REQUIRE. Un valor de 'SSL'
  generará una instrucción GRANT ... REQUIRE SSL. Consulte la documentación de MYSQL GRANT
  (https://dev.mysql.com/doc/refman/5.7/en/grant.html) para obtener más información. Se ignora si la versión de MySQL es inferior a 5.7.0.

- `grant:` (opcional) si también otorgar al usuario privilegios para otorgar los mismos privilegios a otros usuarios.

## Author Information

Juan Manuel Payán Barea    (IT Technician) [st4rt.fr0m.scr4tch@gmail.com](mailto:st4rt.fr0m.scr4tch@gmail.com)

[jpaybar (Juan M. Payán Barea) · GitHub](https://github.com/jpaybar)

https://es.linkedin.com/in/juanmanuelpayan
