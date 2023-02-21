# TERRAFORM:

# Cómo crear una infraestructura paso a paso con Terraform en la nube privada OpenStack

###### By Juan Manuel Payán / jpaybar

st4rt.fr0m.scr4tch@gmail.com

En este tutorial, crearemos una infraestructura básica en `OpenStack` usando `Terraform`, el cual será la continuación de la publicación anterior sobre el uso de `Terraform`, aunque esta vez, nuestro proveedor no será `MySQL` sino la nuebe privada:
[Terraform/README.md at main · jpaybar/Terraform · GitHub](https://github.com/jpaybar/Terraform/blob/main/Terraform_introduccion_mysql_provider/README.md)

Instalaremos el cliente python de `OpenStack` para poder gestionar nuestra nube privada desde un equipo remoto via consola (está fuera de tutorial ya que gestionaremos con `Terraform`, pero de esta forma podrémos verificar los cambios llevados a cabo), aunque en este tutorial tendremos acceso via web con `Horizon`. En nuestro fichero principal de configuración `main.tf` declararemos nuestro proveedor `OpenStack` y los datos de la conexión.
Crearemos un fichero `.tf` `HCL` por cada recurso a crear en `OpenStack`, subiremos una cláve pública de nuestro `keypair`, también una `imágen` de `Ubuntu 20.04`, crearemos `IP's flotantes`, `grupos de seguridad`, añadiremos `reglas`, `redes y subredes` y por último configuraremos una `instancia con Ubuntu 20.04 Focal Fossa` a partir de la imágen que subiremos.

##### **NOTA:**

**Dejaremos la instalación del cliente python `OpenStack` para el final del tutorial.**

### Automatizar la creación y gestión de recursos en `OpenStack`

Desde que tuve mi primer contacto con `OpenStack`, empezando por supuesto por la interfaz web `Horizon` y posteriormente con la linea de comandos, uno siempre piensa en una gestión más cómoda, rápida y segura del sistema. Como Administrador o Técnico IT el primer recurso del que hacemos uso es el `scripting` (`Bash`, `PowerShell`, `Python`, etc...) y eso fué lo que hicé en un principio...

[OpenStack/Create_Openstack_Network_Infraestructure.sh at main · jpaybar/OpenStack · GitHub](https://github.com/jpaybar/OpenStack/blob/main/Openstack%20CLI%20-%20Create%20a%20Basic%20Network%20Infraestructure/Create_Openstack_Network_Infraestructure.sh)

[Deploy N instances automatically](https://github.com/jpaybar/Shell_scripting/blob/main/Openstack%20CLI%20-%20Task%20Automation%20With%20Scripts/Deploy%20N%20instances%20automatically/Deploy_N_instances_automatically.sh)

Evidentemente no tardé mucho siendo usuario de `Ansible` en buscar un módulo que me facilitara dichas tareas...

[How to deploy an instance on Openstack and provision it with WordPress using Ansible](https://github.com/jpaybar/Ansible/tree/main/Ansible-playbooks/Deploy%20an%20instance%20on%20Openstack%20and%20provision%20it%20with%20WordPress%20using%20Ansible)

Pero definitivamente hasta que no usas una herramienta de orquestación como `Terraform` no ves con claridad la facilidad y la potencia que tiene frente a una herramienta de automatización, gestión y configuración como es `Ansible`.

Se puede apreciar perfectamente si hacemos uso de una y otra herramienta para crear recursos en `OpenStack`, desde la simplicidad del código que usamos con los ficheros `HashiCorp Configuration Language` (y no es que los ficheros `yaml` sean complejos), hasta la velocidad de ejecución de dichos `scripts` o `playbooks`.

### Archivo de configuración principal `main.tf`

Lo primero que haremos será crear el directorio de nuestro proyecto, lo llamaremos `terraform_openstack`:

```bash
mkdir terraform_openstack
cd terraform_openstack
```

Creamos el fichero principal de configuración, donde estableceremos los datos del proveedor y de conexión a nuestro proyecto en la nube (en mi caso voy a coger el proyecto `admin`). El fichero se llamará `main`:

```hcl
# https://registry.terraform.io/providers/terraform-provider-openstack/openstack/1.48.0/docs#example-usage

# Define required providers
terraform {
required_version = ">= 0.14.0"
  required_providers {
    openstack = {
      source  = "terraform-provider-openstack/openstack"
      version = "~> 1.48.0"
    }
  }
}

# Configure the OpenStack Provider
provider "openstack" {
  user_name   = "admin"
  tenant_name = "admin"
  password    = "openstack"
  auth_url    = "http://192.168.56.15/identity"
  region      = "RegionOne"
}
```

En la siguiente URL tenemos las configuraciones de ejemplo y como crear nuestros recursos en `OpenStack`:

[Terraform Registry](https://registry.terraform.io/providers/terraform-provider-openstack/openstack/latest/docs)

### Inicializamos el Proveedor

Desde el directorio de nuestro proyecto ejecutamos el primer comando `terraform init` para inicializar el proveedor, éste descargará los plugins necesarios y los instalará en dicha carpeta conforme a la versión que hayamos definido en el fichero.

Ejecutamos el comando y obtendremos una salida similar a la siguiente:

```bash
terraform init
```

```bash
vagrant@devstack:~/terraform_openstack$ terraform init

Initializing the backend...

Initializing provider plugins...
- Finding terraform-provider-openstack/openstack versions matching "~> 1.48.0"...
- Installing terraform-provider-openstack/openstack v1.48.0...
- Installed terraform-provider-openstack/openstack v1.48.0 (self-signed, key ID 4F80527A391BEFD2)

Partner and community providers are signed by their developers.
If you'd like to know more about provider signing, you can read about it here:
https://www.terraform.io/docs/cli/plugins/signing.html

Terraform has created a lock file .terraform.lock.hcl to record the provider
selections it made above. Include this file in your version control repository
so that Terraform can guarantee to make the same selections by default when
you run "terraform init" in the future.

Terraform has been successfully initialized!

You may now begin working with Terraform. Try running "terraform plan" to see
any changes that are required for your infrastructure. All Terraform commands
should now work.

If you ever set or change modules or backend configuration for Terraform,
rerun this command to reinitialize your working directory. If you forget, other
commands will detect it and remind you to do so if necessary.
```

### Subir un `keypair` a nuestro proyecto en `OpenStack`

Crearemos un fichero llamado `0_subir_keypair.tf` con el siguiente contenido:

```hcl
# Subir Par de claves
# https://registry.terraform.io/providers/terraform-provider-openstack/openstack/latest/docs/resources/compute_keypair_v2

resource "openstack_compute_keypair_v2" "keypair" {
  name       = "jpayan"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQC5bDZRiizEWRrpHrONWW7T3e+h5zalGDIbH+XDOM/X5POSZIH6dtIT5No0cxDkdro+56yqT2aJqi+EWIOkGZbxoj1IUiubmxs7J25zMnFNU2nFdJOysSLGVDFsnxTiV3gkz0TcaklFDO4zumfAwH8cIi3CRTU5W0Buqk+eE6zkG86hV4T3zivs9qP/b27Kn9LxMGKny8oNBC4OqvWRe46RLW9rIdgaGxzS+VqA/jH9qm0YQ6P3brFGLEe4XYkL2Lj0jGJ0ycXwJSYkqH9gFSen9/kiZGnkzvEVR0Ivs1hmRGpleoPje2LlV2SccXem0tb3WuPSR5TYiFDSQvIkF920Bpw1090gODmurwYYbBD5El5ovTdvEGn779jjl+y0lvAIjZ45+AU6qQiDMG/TSmj37jpXqVz54JpyUPb1ZekPNWIZy9abzYKPX07XGU1Y51gC1VOPAxZEcp/YrYIa7ztDdN6cS1lQbZ2mb5lbasZgfHEZfoc7ji1r7qK3x8QRZl8= vagrant@devstack"
}
```

En el contenido del fichero solo declaramos el recurso, en este caso `openstack_compute_keypair` y le asignamos in `id` llamado `keypair`, declaramos dos directivas `name` (el nombre de nuestro `keypair` en el proyecto) y `public_key` que será la clave pública de nuestro directorio `.ssh`.

```bash
vagrant@devstack:~/terraform_openstack$ ls -la ~/.ssh/
total 24
drwx------  2 vagrant vagrant 4096 Feb 17 15:06 .
drwxr-xr-x 10 vagrant vagrant 4096 Feb 20 10:42 ..
-rw-------  1 vagrant vagrant  409 Aug 12  2021 authorized_keys
-rw-------  1 vagrant vagrant 2602 Feb 17 15:06 id_rsa
-rw-r--r--  1 vagrant vagrant  570 Feb 17 15:06 id_rsa.pub
-rw-r--r--  1 vagrant vagrant  444 Feb 20 09:24 known_hosts
```

Si no especificamos la directiva `public_key`, `terraform` creará una clave por nosotros que estará generada por el módulo de computación de `OpenStack` `Nova`.

Ejecutamos el comando `terraform plan` para ver el estado final al que queremos llegar:

```bash
vagrant@devstack:~/terraform$ terraform plan
openstack_compute_keypair_v2.test-keypair: Refreshing state... [id=my-keypair]

Terraform used the selected providers to generate the following execution plan. Resource actions are indicated with the following symbols:
  + create
  - destroy

Terraform will perform the following actions:

  # openstack_compute_keypair_v2.keypair will be created
  + resource "openstack_compute_keypair_v2" "keypair" {
      + fingerprint = (known after apply)
      + id          = (known after apply)
      + name        = "jpayan"
      + private_key = (known after apply)
      + public_key  = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQC5bDZRiizEWRrpHrONWW7T3e+h5zalGDIbH+XDOM/X5POSZIH6dtIT5No0cxDkdro+56yqT2aJqi+EWIOkGZbxoj1IUiubmxs7J25zMnFNU2nFdJOysSLGVDFsnxTiV3gkz0TcaklFDO4zumfAwH8cIi3CRTU5W0Buqk+eE6zkG86hV4T3zivs9qP/b27Kn9LxMGKny8oNBC4OqvWRe46RLW9rIdgaGxzS+VqA/jH9qm0YQ6P3brFGLEe4XYkL2Lj0jGJ0ycXwJSYkqH9gFSen9/kiZGnkzvEVR0Ivs1hmRGpleoPje2LlV2SccXem0tb3WuPSR5TYiFDSQvIkF920Bpw1090gODmurwYYbBD5El5ovTdvEGn779jjl+y0lvAIjZ45+AU6qQiDMG/TSmj37jpXqVz54JpyUPb1ZekPNWIZy9abzYKPX07XGU1Y51gC1VOPAxZEcp/YrYIa7ztDdN6cS1lQbZ2mb5lbasZgfHEZfoc7ji1r7qK3x8QRZl8= vagrant@devstack"
      + region      = (known after apply)
      + user_id     = (known after apply)
    }
```

y por último ejecutamos `terraform apply`, el cual nos pedirá que escribamos confirmación para llevar a cabo los cambios `yes`.

Para más detalles de configuración del recurso `openstack_compute_keypair_v2` visitar la documentación oficial:

[openstack_compute_keypair_v2]([Terraform Registry](https://registry.terraform.io/providers/terraform-provider-openstack/openstack/latest/docs/resources/compute_keypair_v2))

Comprovamos con `Horizon` que nuestro `keypair` se ha creado correctamente:

![0_subir_keypair.PNG](C:\LABO\vagrant\TERRAFORM\Terraform_Openstack\_images\0_subir_keypair.PNG)

### Crear un Volúmen

Creamos un fichero llamado `1_crear_volumen.tf`:

```hcl
# Crear Volumen
# https://registry.terraform.io/providers/terraform-provider-openstack/openstack/latest/docs/resources/blockstorage_volume_v2

resource "openstack_blockstorage_volume_v2" "volumen" {
  name        = "volumen_1"
  description = "Volumen de Pruebas de 1Gb"
  size        = 1
  volume_type = "lvmdriver-1"
  availability_zone = "nova"
}
```

El procedimiento sería el mismo, `terraform plan` y `terraform apply`.

![1_crear_volumen.PNG](C:\LABO\vagrant\TERRAFORM\Terraform_Openstack\_images\1_crear_volumen.PNG)

### Subir una imágen

Subiremos una imágen de `Ubuntu 20.04 Focal Fossa` con la que posteriormente levantaremos una `instancia` asignandole el `sabor` `d2`. Nuestro fichero se llamará `2_subir_imagen.tf`.

Descargamos la imágen en formato `qcow2` al directorio de nuestro proyecto:

```bash
wget https://cloud-images.ubuntu.com/focal/current/focal-server-cloudimg-amd64.img
```

Fichero `tf`:

```hcl
# Subir imagen Ubuntu 20.04
# https://registry.terraform.io/providers/terraform-provider-openstack/openstack/latest/docs/resources/images_image_v2

resource "openstack_images_image_v2" "imagen_ubuntu2004" {
  name   = "Ubuntu 20.04 Focal Fossa"
  local_file_path = "/home/vagrant/terraform_openstack/focal-server-cloudimg-amd64.img"
  container_format = "bare"
  disk_format = "qcow2"
}
```

Definimos el `id` del recurso `openstack_images_image_v2` con el nombre `imagen_ubuntu2004` y definimos las directivas `name`, `local_file_path`, `container_format` y `disk_format`. 

![2_subir_imagen.png](C:\LABO\vagrant\TERRAFORM\Terraform_Openstack\_images\2_subir_imagen.png)

### Solicitar una `IP Flotante`

Fichero `3_crear_ip_flotante.tf`

```hcl
# Crea IP Flotante
# https://registry.terraform.io/providers/terraform-provider-openstack/openstack/latest/docs/resources/compute_floatingip_v2

resource "openstack_compute_floatingip_v2" "ip" {
  pool = "public"
}
```

![3_crear_ip_flotante.PNG](C:\LABO\vagrant\TERRAFORM\Terraform_Openstack\_images\3_crear_ip_flotante.PNG)

### Crear un `Grupo de Seguridad`

Fichero `4_crear_grupo_seguridad.tf`

```hcl
# Crear Grupo de Seguridad
# https://registry.terraform.io/providers/terraform-provider-openstack/openstack/latest/docs/resources/networking_secgroup_v2

resource "openstack_networking_secgroup_v2" "grupo_seguridad" {
  name        = "grupo_seguridad_1"
  description = "Cread desde Terraform"
  tenant_id   = "172ea88ae193456384de58b097052ee6"
}
```

El `id` del recurso será `grupo_seguridad`, y el nombre con el que se creará en `OpenStack` `grupo_seguridad_1`.

![4_crear_grupo_seguridad.png](C:\LABO\vagrant\TERRAFORM\Terraform_Openstack\_images\4_crear_grupo_seguridad.png)

### Agregar una regla de seguridad

Ahora agregaremos una regla de seguridad de `entrada` para el protocólo `SSH` al grupo de seguridad que hemos creado previamente. Creamos el fichero llamado `5_añadir_regla_ssh.tf`:

```hcl
# Crear Regla SSH de entrada para toda la red
# https://registry.terraform.io/providers/terraform-provider-openstack/openstack/latest/docs/resources/networking_secgroup_rule_v2

resource "openstack_networking_secgroup_rule_v2" "ssh_rule" {
  direction         = "ingress" # Regla de Entrada
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 22
  port_range_max    = 22
  remote_ip_prefix  = "0.0.0.0/0" # Para toda la red
  security_group_id = "960eef7e-267f-4afd-90b0-a3a72489e0b2"
}
```

`id` del recurso `ssh_rule`, analizamos las directivas:

- `direction:` Sentido en que se aplicará la regla (entrada o salida).

- `ethertype:` Versión del protocólo, IPv4 ó IPv6.

- `protocol:` Protocólo (tcp, udp, icmp...).

- `port_range_min:` Intervalo minimo de puerto a aplicar.

- `port_range_max:` Intervalo máximo de puerto a aplicar.

- `remote_ip_prefix:` Dirección IP o rango de red al que se aplica la regla.

- `security_group_id:` Id del grupo de seguridad al que queremos añadir la regla.

![5_añadir_regla_ssh.PNG](C:\LABO\vagrant\TERRAFORM\Terraform_Openstack\_images\5_añadir_regla_ssh.PNG)

Verificamos que ahora podemos acceder a las instancias que pertenezcan a dicho grupo de seguridad por `SSH`:

![conexion_instancia.PNG](C:\LABO\vagrant\TERRAFORM\Terraform_Openstack\_images\conexion_instancia.PNG)

### Crear una Red

Creamos el fichero `6_crear_red.tf`

```hcl
# Crear Red
# https://registry.terraform.io/providers/terraform-provider-openstack/openstack/latest/docs/resources/networking_network_v2

resource "openstack_networking_network_v2" "red1" {
  name           = "Red creada con Terraform"
  admin_state_up = "true"
  tenant_id      = "172ea88ae193456384de58b097052ee6"
}
```

![6_crear_red.png](C:\LABO\vagrant\TERRAFORM\Terraform_Openstack\_images\6_crear_red.png)

### Crear una Subred

Fichero `7_crear_subred.tf`

```hcl
# Crea Subred
# https://registry.terraform.io/providers/terraform-provider-openstack/openstack/latest/docs/resources/networking_subnet_v2

resource "openstack_networking_subnet_v2" "subred1" {
  network_id = "2c058666-4dda-48c3-8433-af2eb120d90f"
  cidr       = "10.10.10.0/26"
  name       = "subred_terraform"
  tenant_id  = "172ea88ae193456384de58b097052ee6"
}
```

Asignamos al recurso el `id` llamado `subred1` y la directivas serán:

- `network_id:` `id` de la red a la que se asocia.

- `cidr:` Rango de red en el que se asignaran `Fixed IPs`.

- `name:` Nombre identificativo de la Subred.

- `tenant_id:` `id` del proyecto.

![7_crear_subred.png](C:\LABO\vagrant\TERRAFORM\Terraform_Openstack\_images\7_crear_subred.png)

### Crear un Router con conexión a la Red Pública

Creamos nuestro fichero de configuración `8_crear_router.tf`

```hcl
# Crea Router Conectado a la Red Publica
# https://registry.terraform.io/providers/terraform-provider-openstack/openstack/latest/docs/resources/networking_router_v2

resource "openstack_networking_router_v2" "router1" {
  name             = "router1"
  external_network_id = "2526aa80-f92d-421e-a157-72e2812de673" # Id de la Red Publica
  tenant_id        = "172ea88ae193456384de58b097052ee6"
}
```

En `external_network_id` asignamos el `id` de la Red Pública y en `tenant_id` igual que anteriormente el `id` del proyecto.

![8_crear_router.PNG](C:\LABO\vagrant\TERRAFORM\Terraform_Openstack\_images\8_crear_router.PNG)

### Crear una interfaz en el Router para conectarlo a una Subred

En este fichero `9_crear_interfaz_router.tf` configuramos la creación de una interfaz en el router `router1`  para conectarlo a la subred que hemos creado anteriormente `subred_terraform`.

```hcl
# Crear Interfaz en un Router
# https://registry.terraform.io/providers/terraform-provider-openstack/openstack/latest/docs/resources/networking_router_interface_v2

resource "openstack_networking_router_interface_v2" "interfaz_router1" {
  router_id = "bfaa53f9-fda6-459c-abfc-3a4396aa74ab"
  subnet_id = "91a9207c-432e-4b5a-abef-25fe87780f22"
}
```

![9_crear_interfaz_router.PNG](C:\LABO\vagrant\TERRAFORM\Terraform_Openstack\_images\9_crear_interfaz_router.PNG)

### Crear una `Instancia` con la imágen de `Ubuntu 20.04`

Por último vamos a crear una instancia con la imágen que descargamos anteriormente de `Ubuntu 20.04`, le asignaremos el `flavor` `d2`, el `keypair` que creamos llamado `jpayan`, la agregaremos al grupo de seguridad `grupo_seguridad_1`, la conectamos a la red creada y le asignamos una `IP Flotante` que ya habiamos reservado anteriormente.

`10_crear_instancia.tf`

```hcl
# Crear una Instancia
# https://registry.terraform.io/providers/terraform-provider-openstack/openstack/latest/docs/resources/compute_instance_v2

resource "openstack_compute_instance_v2" "instancia" {
  name            = "instancia_ubuntu2004"
  image_id        = "89b6fd42-7215-4d6f-b851-bfcb25527289"
  flavor_id       = "d2"
  key_pair        = "jpayan"
  security_groups = ["grupo_seguridad_1"]

  network {
    name = "Red creada con Terraform"
  }

  metadata = {
    "Instancia creada con" = "Terraform"
  }
}

# Asocia IP Flotante a una Instancia
# https://registry.terraform.io/providers/terraform-provider-openstack/openstack/latest/docs/resources/compute_floatingip_associate_v2

resource "openstack_compute_floatingip_associate_v2" "floating_ip" {
  floating_ip = "${openstack_compute_floatingip_v2.ip.address}"
  instance_id = "${openstack_compute_instance_v2.instancia.id}"
}
```

Como se puede observar en el código, aqui declaramos dos recursos, uno es `openstack_compute_instance_v2` para crear la instancia propiamente dicha y el otro `openstack_compute_floatingip_associate_v2` para asociar la dirección `IP Flotante` que reservamos anteriormente a la instancia que estamos creando. Las directivas dentro de este último recurso (`floating_ip` y `instance_id`) serán definidas con variables. El valor de `floating_ip` apunta al recurso `openstack_compute_floatingip_v2` que creamos anteriormente en el fichero `3_crear_ip_flotante.tf` con `id` `ip` como podemos ver:

```hcl
# Crea IP Flotante
# https://registry.terraform.io/providers/terraform-provider-openstack/openstack/latest/docs/resources/compute_floatingip_v2

resource "openstack_compute_floatingip_v2" "ip" {
  pool = "public"
}
```

Y la directiva `instance_id` que apunta al recurso que hemos definido en el fichero para crear la instancia con `id` `instancia`.

![10_crear_instancia.png](C:\LABO\vagrant\TERRAFORM\Terraform_Openstack\_images\10_crear_instancia.png)

Para finalizar, asociaremos el volúmen que creamos al principio a esta instancia.

```hcl
# Asociar un Volumen a una Instancia
# https://registry.terraform.io/providers/terraform-provider-openstack/openstack/latest/docs/resources/compute_volume_attach_v2

resource "openstack_compute_volume_attach_v2" "asociar_volumen" {
  instance_id = "57a7c5f4-6a41-4aeb-b564-5d329339afdb"
  volume_id  = "14f22def-cfd4-4063-9912-5779de9b2d1e"
}
```

![11_asociar_volumen.png](C:\LABO\vagrant\TERRAFORM\Terraform_Openstack\_images\11_asociar_volumen.png)

Y hasta aquí, habremos creado una pequeña infraestructura desde cero. Si quisieramos eliminar todos los cambios hechos en nuestro proyecto, sería tan fácil como ejecutar el comando `terraform apply -destroy` o directamente su alias `terraform destroy`.

### Instalación del cliente `python` de `OpenStack` `CLI`

Instalación para `Ubuntu 20.04`

```bash
sudo apt-get install python3-dev python3-pip
mkdir openstack_client
sudo apt-get install python3-virtualenv
cd openstack_client
virtualenv python-openstackclient
cd python-openstackclient
source bin/activate
pip install python-openstackclient
```

Una vez realizada la instalación del cliente deberemos llamar a nuestro fichero `RC` con los datos de conexión:

```bash
source admin-openrc.sh
```

Ahora podremos ejecutar cualquier comando de `OpenStack` desde el equipo remoto sobre nuestro proyecto.

```bash
vagrant@masterVM:~$ openstack flavor list
+----+-----------+-------+------+-----------+-------+-----------+
| ID | Name      |   RAM | Disk | Ephemeral | VCPUs | Is Public |
+----+-----------+-------+------+-----------+-------+-----------+
| 1  | m1.tiny   |   512 |    1 |         0 |     1 | True      |
| 2  | m1.small  |  2048 |   20 |         0 |     1 | True      |
| 3  | m1.medium |  4096 |   40 |         0 |     2 | True      |
| 4  | m1.large  |  8192 |   80 |         0 |     4 | True      |
| 5  | m1.xlarge | 16384 |  160 |         0 |     8 | True      |
| c1 | cirros256 |   256 |    1 |         0 |     1 | True      |
| d1 | ds512M    |   512 |    5 |         0 |     1 | True      |
| d2 | ds1G      |  1024 |   10 |         0 |     1 | True      |
| d3 | ds2G      |  2048 |   10 |         0 |     2 | True      |
| d4 | ds4G      |  4096 |   20 |         0 |     4 | True      |
+----+-----------+-------+------+-----------+-------+-----------+
```

## Author Information

Juan Manuel Payán Barea    (IT Technician) [st4rt.fr0m.scr4tch@gmail.com](mailto:st4rt.fr0m.scr4tch@gmail.com)
[jpaybar (Juan M. Payán Barea) · GitHub](https://github.com/jpaybar)
https://es.linkedin.com/in/juanmanuelpayan
