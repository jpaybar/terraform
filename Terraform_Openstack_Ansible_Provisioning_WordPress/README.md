# TERRAFORM + ANSIBLE:

# Como desplegar una instancia en OpenStack con Terraform y aprovionar la con WordPress usando Ansible

###### By Juan Manuel Payán / jpaybar

st4rt.fr0m.scr4tch@gmail.com

##### **NOTA:**

**El despliegue de `WordPress` es muy básico y está hecho para un entorno de pruebas y desarrollo y no para producción. No hay `hardening` ni securización y el acceso es via `HTTP` al puerto 80.**

`Ansible` es una herramienta de administración para realizar configuraciones y automatizar procesos, para ello hace uso de scripts llamados `playbooks`. Estas listas contienen acciones y tareas escritas en `YAML`. Podemos realizar operaciones como instalar y actualizar software, crear y eliminar usuarios y configurar servicios del sistema, etc... Por lo tanto es la herramienta adecuada para aprovisionar servidores que hayamos implementado con `Terraform`, ya que dichos recursos se crearan en blanco de forma predeterminada.
`Terraform` por otro lado nos permite definir y crear la infraestructura del sistema, que abarca el hardware en el que se ejecutarán nuestras aplicaciones, para ello, `Ansible` configurará e implementará el software mediante la ejecución de sus `playbooks` en dichas instancias. 
En este tutorial desplegaremos una instancia con `Terraform` e inmediatamente después de su creación, la aprovisionaremos con la apliación `WordPress` usando un `Playbook de Ansible`.
Para ello haremos uso de los `proveedores genéricos de Terraform` "remote-exec" y "local-exec", estos nos brindan la posibilidad de ejecutar comandos en la propia instancia de forma remota o ejecutar scripts en local (máquina desde la que usamos `Terraform`) con la instancia creada. Es aquí donde configuraremos nuestro `playbook` de `Ansible` para que instale y configure `WordPress` en nuestra instancia, la cual habremos creado en `OpenStack` previamente con las primeras lineas de código de nuestro `script HCL de Terraform`.

https://www.terraform.io/

https://www.ansible.com/

### Estructura del directorio de Proyecto

Nuestro directorio llamado `Terraform_Openstack_Ansible_Provisioning_WordPress` contiene los siguientes ficheros:

```bash
vagrant@masterVM:~$ tree 
.
├── cloud-init.sh
├── main.tf
├── README.md
├── setup_proxy.sh
├── variables.tf
├── wordpress
│   ├── files
│   │   ├── apache.conf.j2
│   │   └── wp-config.php.j2
│   ├── playbook.yml
│   └── vars
│       └── default.yml
└── wordpress_instance_deployment.tf
```

#### `cloud-init.sh`:

`cloud-init` es un paquete de software que automatiza la inicialización de las instancias de la nube durante el arranque del sistema. Dichas instancias tienen preinstalado este software. En este tutorial se ha creado dicho fichero pero no lo usaremos, aunque hayamos incluido la directiva `user_data = file("cloud-init.sh")` desde la que llamariamos a dicho `script` para su ejecución.

Para más información visitar la documentación oficial:

[User data formats - cloud-init 23.1 documentation](https://cloudinit.readthedocs.io/en/latest/explanation/format.html#user-data-script)

#### `main.tf`:

Será el fichero de configuración principal de `Terraform`, en el declaramos el proveedor (en este caso `OpenStack` y los datos de conexión a nuestro proyecto en la nube). 

[Terraform Registry](https://registry.terraform.io/providers/terraform-provider-openstack/openstack/latest/docs)

El contenido del fichero es el siguiente:

```hcl
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

##################################################################################
## Change the OS_USERNAME, OS_PASSWORD, etc... variables or source your RC file ##
##################################################################################

# Configure the OpenStack Provider

#provider "openstack" {
#  user_name         = "OS_USERNAME"
#  tenant_name       = "OS_PROJECT_NAME"
#  tenant_id         = "OS_PROJECT_ID"
#  password          = "OS_PASSWORD"
#  auth_url          = "OS_AUTH_URL"
#  region            = "OS_REGION_NAME"
#  user_domain_name  = "OS_USER_DOMAIN_NAME"
#  project_domain_id = "OS_PROJECT_DOMAIN_ID"
#}
```

En la primera parte definimos el proveedor que será inicializado con el comando `terraform init` el cual descargará e instalará los plugins necesarios en dicho directorio. La segunda parte está comentada ya que tenemos 2 opciones, usar las variables declaradas en dicho fichero, o hacer un `source` de nuestro fichero `RC` el cual podremos bajar desde nuestro proyecto en `Openstack`.

En este caso lo primero que debemos hacer es ejecutar el siguiente comando:

```bash
source demo-openrc.sh
```

donde `demo-openrc.sh` es el nombre de nuestro fichero `RC` para el proyecto `demo`.

https://docs.openstack.org/zh_CN/user-guide/common/cli-set-environment-variables-using-openstack-rc.html

#### `README.md`:

Este mismo fichero.

#### `setup_proxy.sh`:

Script de `Bash` que usaremos en este caso para configurar nuestro proxy en la instancia, se ejecutará usando el proveedor genérico de `Terraform` "remote-exec" que veremos un poco más adelante en el fichero de despliegue.

¿Y porqué no configurarlo directamente desde nuestro playbook de `Ansible`?

Porque nos servirá como guia de comprobación de que el servicio `SSH` esta disponible para que después `Ansible` haga su trabajo.

El contenido del script es muy básico:

```bash
#!/bin/bash

echo 'export http_proxy="http://your.proxy.here:8080"' | sudo tee -a /etc/environment
echo 'export https_proxy="http://your.proxy.here:8080"' | sudo tee -a /etc/environment
echo 'export no_proxy="localhost,127.0.0.1,192.168.56.0/24,192.168.56.224/27"' | sudo tee -a /etc/environment
```

#### `variables.tf`:

En este fichero definimos las variables que usaremos en nuestro script de `Terraform` para el despliegue de la instancia en `Openstack`. Esto nos permitirá poder usar nuestro script con diferentes configuraciones.

```hcl
variable "tf_keypair_name" {
    description = "Nombre del keypair a insertar en la Instancia."
    default  = "jpayan"
}

variable "tf_private_key" {
    description = "Path a la clave privada."
    default  = "~/.ssh/id_rsa"
}

variable "tf_public_key" {
    description = "Path a la clave pública."
    default  = "~/.ssh/id_rsa.pub"
}

variable "tf_network" {
    description = "Nombre de la Red."
    default  = "private"
}

variable "tf_instance" {
    description = "Nombre de la Instancia."
    default  = "Ubuntu_20.04_WordPress"
}

variable "tf_image_id" {
    description = "ID de la imágen."
    default  = "31356b48-ecef-4f3a-b31d-c82f8fe7ed16"
}

variable "tf_flavor_id" {
    description = "ID del sabor."
    default  = "d2"
}

variable "tf_floating_ip_pool" {
    description = "Pool para obtener las IP's Flotantes."
    default = "public"
}

variable "tf_security_groups" {
    description = "Lista de los Grupos de Seguridad a los que pertenecerá la Instancia."
    type = list
    default = ["default"]
}
```

#### `wordpress`:

Este directorio contiene el playbook de `Ansible` que aprovisionará la instancia con dicha aplicación y que se llamará desde el proveedor genérico de `Terraform `"local-exec".

```bash
vagrant@masterVM:~$ tree wordpress
wordpress
├── files
│   ├── apache.conf.j2
│   └── wp-config.php.j2
├── playbook.yml
└── vars
    └── default.yml
```

[Ansible/Ansible-playbooks/WORDPRESS_LAMP_ubuntu1804_2004 at main · jpaybar/Ansible · GitHub](https://github.com/jpaybar/Ansible/tree/main/Ansible-playbooks/WORDPRESS_LAMP_ubuntu1804_2004)

#### `wordpress_instance_deployment.tf`:

Este es el fichero con el que se desplegará nuestra instancia, hay que mencionar que no es el único recurso `resource` definido, ya que para levantar una instancia en la nube (en este caso `Openstack`) necesitamos declarar otros recursos si estos no están aún en nuestro proyecto o si queremos crear los especificamente para usarlos con dicha instancia (`keypair`, `IP Flotante`, etc...).

Veamos el contenido del script y vamos comentando cada sección:

```hcl
resource "openstack_compute_instance_v2" "Instance" {
  name = var.tf_instance
  flavor_id = var.tf_flavor_id
  image_id = var.tf_image_id
  key_pair = var.tf_keypair_name
  security_groups = var.tf_security_groups
  network {
    name = var.tf_network
  }
  metadata = {
    "Instance created by" = "Terraform"
  }
  user_data = file("cloud-init.sh")
}

resource "openstack_compute_keypair_v2" "keypair" {
  name       = var.tf_keypair_name
  public_key = file(var.tf_public_key)
}

resource "openstack_networking_floatingip_v2" "fip" {
  pool = var.tf_floating_ip_pool
}

resource "openstack_compute_floatingip_associate_v2" "fip" {
  floating_ip = openstack_networking_floatingip_v2.fip.address
  instance_id = openstack_compute_instance_v2.Instance.id

  # Ejecuta comandos en la propia instancia
  # https://developer.hashicorp.com/terraform/language/resources/provisioners/remote-exec
  provisioner "remote-exec" {
    script = "setup_proxy.sh"

  connection {
    host        = "${openstack_networking_floatingip_v2.fip.address}"
    type        = "ssh"
    user        = "ubuntu"
    agent       = false
    private_key = file(var.tf_private_key)
    }
  }

  # Ejecuta el playbook de "Ansible" que aprovisionará la instancia con "WordPress"
  # https://developer.hashicorp.com/terraform/language/resources/provisioners/local-exec
  provisioner "local-exec" {
    environment = {
      PUBLIC_IP                 = "${openstack_networking_floatingip_v2.fip.address}"
      PRIVATE_IP                = "${openstack_compute_instance_v2.Instance.access_ip_v4}"
      ANSIBLE_HOST_KEY_CHECKING = "False"
    }

    working_dir = "wordpress/"
    command     = "ansible-playbook -u ubuntu --private-key=${var.tf_private_key} -i ${openstack_networking_floatingip_v2.fip.address}, playbook.yml"
  }
}

## Mostramos los valores de las IP's de la instancia al ejecutar "terraform apply"
## Podemos volver a verlos ejecutando "terraform output"

output "instance_ip" {
    value = openstack_compute_instance_v2.Instance.access_ip_v4
}

output "float_ip" {
    value = openstack_networking_floatingip_v2.fip.address
}
```

#### `resource "openstack_compute_instance_v2" "Instance"`:

El primer recurso que definimos es nuestra instancia propiamente dicha, para ello usamos el `resource` `"openstack_compute_instance_v2"` y el `id` de dicho recurso será `"Instance"`.

Asignamos los datos básicos como `nombre`, `sabor`, `imágen` que usaremos (en este caso `Ubuntu 20.04`), `keypair`, `grupos de seguridad` y la `red` a la que conectaremos dicha instancia.

[Launch an instance &#8212; Installation Guide documentation](https://docs.openstack.org/install-guide/launch-instance.html)

Tenemos otras dos parejas tipo `clave`:`valor` que son:

`metadata`: En ella definimos información que queramos destacar:

```hcl
"Instance created by" = "Terraform"
```

`user-data`: Podemos proporcionar comandos de configuración que únicamente se ejecutarán en el primer arranque de la instancia o como en este caso `scripts` o ficheros `cloud-config`. En este caso, el script está vacio, pero declaré esta opción simplemente para mostrar la posibilidad de uso.

```hcl
user_data = file("cloud-init.sh")
```

En el siguiente enlace, uso `cloud-config` para personalizar una instancia desplegada en `Openstack` pero esta vez usando el módulo de `Ansible`:

[OpenStack/Deploy_Openstack_Instance_And_Provisioning_WordPress.yml at main · jpaybar/OpenStack · GitHub](https://github.com/jpaybar/OpenStack/blob/main/Openstack%20CLI%20-%20Task%20Automation%20With%20Scripts/Deploy%20an%20instance%20on%20Openstack%20and%20provision%20it%20with%20WordPress%20using%20Ansible/Deploy_Openstack_Instance_And_Provisioning_WordPress.yml)

#### `resource "openstack_compute_keypair_v2" "keypair"`:

El siguiente recurso será definir un `keypair`, para ello usaremos un pareja de claves pública/privada que hemos generado previamente en el sistema con `ssh-keygen`, por lo tanto lo que haremos será importar la clave pública en `Openstack` para después poder inyectarla en nuestra instancia.

La variable asignada a `public_key` contiene la ruta a nuestra clave pública:

```bash
vagrant@masterVM:~$ ls -la .ssh/
total 28
drwx------  2 vagrant vagrant 4096 Feb 23 16:57 .
drwxr-xr-x 12 vagrant vagrant 4096 Mar  2 12:19 ..
-rw-------  1 vagrant vagrant  409 Aug 12  2021 authorized_keys
-rw-------  1 vagrant vagrant 2602 Feb 17 15:06 id_rsa
-rw-r--r--  1 vagrant vagrant  570 Feb 17 15:06 id_rsa.pub
-rw-r--r--  1 vagrant vagrant 3108 Mar  2 10:06 known_hosts
```

#### `resource "openstack_networking_floatingip_v2" "fip"`:

Con este recurso solicitamos una `IP Flotante` del `Pool` que tengamos designado y que posteriormente asociaremos a nuestra instancia para poder acceder de forma externa.

#### `resource "openstack_compute_floatingip_associate_v2" "fip"`:

Este es el último recurso que hemos declarado en el fichero `Terraform` para nuestro despliegue y es en el que nos detendremos más, ya que será aquí donde llamaremos a nuestro playbook de `Ansible` que automatizará la instalación de `WordPress` en nuestra instancia con `Ubuntu 20.04`.

Veamos esta parte de código en la que declaramos el recurso:

```hcl
resource "openstack_compute_floatingip_associate_v2" "fip" {
  floating_ip = openstack_networking_floatingip_v2.fip.address
  instance_id = openstack_compute_instance_v2.Instance.id

  # Ejecuta comandos en la propia instancia
  # https://developer.hashicorp.com/terraform/language/resources/provisioners/remote-exec
  provisioner "remote-exec" {
    script = "setup_proxy.sh"

  connection {
    host        = "${openstack_networking_floatingip_v2.fip.address}"
    type        = "ssh"
    user        = "ubuntu"
    agent       = false
    private_key = file(var.tf_private_key)
    }
  }

  # Ejecuta el playbook de "Ansible" que aprovisionará la instancia con "WordPress"
  # https://developer.hashicorp.com/terraform/language/resources/provisioners/local-exec
  provisioner "local-exec" {
    environment = {
      PUBLIC_IP                 = "${openstack_networking_floatingip_v2.fip.address}"
      PRIVATE_IP                = "${openstack_compute_instance_v2.Instance.access_ip_v4}"
      ANSIBLE_HOST_KEY_CHECKING = "False"
    }

    working_dir = "wordpress/"
    command     = "ansible-playbook -u ubuntu --private-key=${var.tf_private_key} -i ${openstack_networking_floatingip_v2.fip.address}, playbook.yml"
  }
}
```

Este `resource` asocia la `IP Flotante` que hemos solicitado anteriormente al `Pool` a nuestra instancia. Podemos ver las claves `floating_ip` e `instance_id` que llaman a dichos recursos creados anteriormente, hasta ahí la función de este `resource` estaría completamente operativa.

Lo que realmente nos interesa de este recurso son los `provisioner` que ya hemos mencionado anteriormente y que en este caso son 2; "remote-exec" y "local-exec". Estos `provisioners`, son genéricos de `Terraform` y los usaremos para ejecutar comandos o scripts en la máquina remota.

##### **NOTA IMPORTANTE:**

**¿Dónde definir los proveedores "remote-exec" y "local-exec"?
Intuitivamente, podríamos pensar que un `provisioner`  de este tipo debería colocarse dentro del bloque de recursos donde hemos definido la instancia, ya que está directamente relacionada con el despligue de la misma, debido a que el `provisioner` se invocará una vez se haya creado dicha instancia, por lo tanto parece un buen plan. 
Pero debemos tener en cuenta que necesitamos algo más que crear la instancia propiamente dicha antes de poder trabajar con ella. Por ejemplo, también necesitamos asignarle una dirección `IP flotante`. Por lo tanto, debemos tener en cuenta donde ubicaremos estos `provisioner` para estar seguros de que se cumplirán todos los requisitos.
Debido a que no se puede crear un recurso de asociación de IP flotante hasta que se hayan creado tanto la instancia como la dirección IP de la que depende, es una excelente ubicación para un proveedor. 
Terraform también proporciona otro tipo de bloque de recursos que no trataremos aqui: el "null resource", la sintaxis es la siguiente:**

```hcl
resource "null_resource" "INTERNAL_NAME" {
  depends_on = [LIST_OF_RESOURCES]
  connection { SYNTAX_AS_SHOWN_ABOVE }
  provisioner "PROVISIONER_TYPE" {
    PROVISIONER_CONTENTS
  }
}
```

Hemos recalcado la **NOTA IMPORTANTE** porque en las primeras pruebas tuve problemas ubicando dichos `provisioner` en el recurso de la instancia, ya que se intentaban ejecutar los bloques de scripts y aún no había una `IP Flotante` asociada, por lo que el servicio `SSH` no podia conectar.

La documentación oficial es algo difusa al respecto y hay tutoriales por internet similares usando nubes públicas como `AWS` o `Digital Ocean` en los que si parece funcionar. 

Desde mi punto de vista, es más logico el enfoque que comento, razonando cuando una instancia es completamente operativa.

### provisioner "remote-exec"

El `provisioner` "remote-exec" de Terraform ejecuta comandos o scripts en un sistema remoto. Un recurso determinado puede contener varios `provisioner` y se ejecutarán en el orden en que aparecen en el recurso. La instancia remota y las credenciales para acceder a ella se especifican mediante un bloque llamado `connection` que se define como parte del bloque `provisioner` o en el bloque principal del recurso.
Los `provisioner` "remote-exec" pueden contener diferentes argumentos para definir su comportamiento (`inline` y `script`):
`inline`: Especifica una lista de comandos para ejecutar en el sistema remoto. `Terraform` en realidad concatena los comandos en un script temporal, lo copia en el sistema remoto y lo ejecuta allí.
`script`: Especifica la ruta a un `script` que contiene los comandos a ejecutar se copiarán en el sistema remoto y luego se ejecutarán allí.
El argumento scripts especifica una lista de rutas a los archivos de script que se copiarán en el sistema remoto y se ejecutarán allí (en el orden indicado). También podemos definir una lista con los `scripts` a ejecutar.

Nosotros hemos definido su comportamiento como `script`, llamará al fichero por lotes `setup_proxy.sh` y configurará el proxy de nuestro sistema. En mi caso es necesario pero podriamos ejecutar la instalación de una version de `Python` en concreto (de la que depende `Ansible`) o cualquier otro paquete o configuración.

Un ejemplo de `inline`:

```hcl
connection {
    type     = "ssh"
    user     = "ubuntu"
    private_key = file(var.tf_private_key)
    host     = "${openstack_networking_floatingip_v2.fip.address}"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo apt-get update",
      "sudo apt-get install -y python3",
    ]
  }
```

[Provisioner: remote-exec | Terraform | HashiCorp Developer](https://developer.hashicorp.com/terraform/language/resources/provisioners/remote-exec)

### provisioner "local-exec"

El `provisioner` genérico "local-exec" ejecuta comandos o scripts en el sistema donde se ejecuta Terraform. Un recurso determinado puede contener varios `provisioner` y se ejecutarán en el orden en que aparecen en el recurso. Los `provisioner`  "local-exec" tienen cuatro argumentos que podemos configurar:

1.- El argumento `command` es obligatorio y especifica el comando que se va a ejecutar.
2.- El argumento `working_dir ` es opcional y establece el directorio de trabajo para el comando.
3.- El argumento `environment` es opcional define valores para un conjunto de variables de entorno que se utilizarán al ejecutar el comando. 
4.- El argumento `interpreter` es opcional se puede usar para definir la shell que se usará al ejecutar la cadena de comandos, junto con los argumentos necesarios. 

Nuestro fragmento de código es el siguiente:

```hcl
provisioner "local-exec" {
    environment = {
      PUBLIC_IP                 = "${openstack_networking_floatingip_v2.fip.address}"
      PRIVATE_IP                = "${openstack_compute_instance_v2.Instance.access_ip_v4}"
      ANSIBLE_HOST_KEY_CHECKING = "False"
    }

    working_dir = "wordpress/"
    command     = "ansible-playbook -u ubuntu --private-key=${var.tf_private_key} -i ${openstack_networking_floatingip_v2.fip.address}, playbook.yml"
  }
```

En `environment` hemos declarado las IP (Flotante y Fixed), en realidad solo nos interesa la `IP Flotante`, la variable `ANSIBLE_HOST_KEY_CHECKING` a false. Estas variables también podriamos declarar las en el fichero `ansible.cfg` ya que afectan directamente al entorno de ejecución de `Ansible`.

En nuestro argumento `working_dir` establecemos el `Path` al directorio que contiene el playbook de `Ansible` para el despliegue de `WordPress` y en el argumento `command` el comando propiamente dicho para ejecutar dicho playbook.

[Provisioner: local-exec | Terraform | HashiCorp Developer](https://developer.hashicorp.com/terraform/language/resources/provisioners/local-exec)

### Ejecución del Despliegue

Empezamos con la inicializacion del proveedor `Openstack` en la carpeta del proyecto, para ello ejecutamos el comando `terraform init`. Una vez descargados los plugins e instalados, podemos ejecutar `terraform plan` para ver el estado deseado al que queremos que llegue el despliegue.

Por último ejecutamos `terraform apply` o `terraform apply -auto-approve` para aplicar los cambios:

![1_terraform_apply.PNG](C:\LABO\vagrant\TERRAFORM\Terraform_Openstack_Ansible_Provisioning_WordPress\_images\1_terraform_apply.PNG)

 Una vez se hayan ejecutados y aplicados los `resources` de nuestro fichero `wordpress_instance_deployment.tf` empieza a ejecutarse el primer `provisioner` "remote-exec":

![2_remote_exec.png](C:\LABO\vagrant\TERRAFORM\Terraform_Openstack_Ansible_Provisioning_WordPress\_images\2_remote_exec.png)

Cuando este termine pasará a ejecutarse el siguiente `provisioner`, en este caso el "local-exec" que ejecutará el playbook de `Ansible`:

![3_local_exec.png](C:\LABO\vagrant\TERRAFORM\Terraform_Openstack_Ansible_Provisioning_WordPress\_images\3_local_exec.png)

Una vez se ejecute el playbook veremos el resultado:

![4_final_output.PNG](C:\LABO\vagrant\TERRAFORM\Terraform_Openstack_Ansible_Provisioning_WordPress\_images\4_final_output.PNG)

Comprobamos en `Openstack` que la instancia se a creado correctamente con `Terraform`:

![5_openstack_instance.png](C:\LABO\vagrant\TERRAFORM\Terraform_Openstack_Ansible_Provisioning_WordPress\_images\5_openstack_instance.png)

Atacamos en el navegador la `IP Flotante` que se nos asigno y vemos la página inicial de instalación de `WordPress`:

![6_wordpress.png](C:\LABO\vagrant\TERRAFORM\Terraform_Openstack_Ansible_Provisioning_WordPress\_images\6_wordpress.png)

## Author Information

Juan Manuel Payán Barea    (IT Technician) [st4rt.fr0m.scr4tch@gmail.com](mailto:st4rt.fr0m.scr4tch@gmail.com)

[jpaybar (Juan M. Payán Barea) · GitHub](https://github.com/jpaybar)

https://es.linkedin.com/in/juanmanuelpayan
