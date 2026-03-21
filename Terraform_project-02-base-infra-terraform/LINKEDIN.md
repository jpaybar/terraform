Infraestructura como Código en OpenStack: Terraform vs Heat

Sigo avanzando en el laboratorio de OpenStack, esta vez desplegando una infraestructura de 3 capas completa usando Terraform y comparándola con OpenStack Heat.

Después de desplegar OpenStack con Sunbeam (que ya compartí anteriormente), el siguiente paso natural era automatizar el despliegue de infraestructura sobre la nube. He querido ir más allá y no solo desplegar, sino hacerlo de forma modular, parametrizada y reutilizable.

Algunos puntos clave del proyecto:

- Arquitectura de 3 capas: proxy inverso Nginx (server1), servidor de aplicaciones Apache+PHP (server2) y base de datos MySQL (server3).
- Infraestructura completamente modularizada en Terraform: redes, routers, security groups, servidores y floating IPs como módulos independientes.
- Sin valores hardcodeados: todos los parámetros (CIDRs, nombres, IPs, DNS) fluyen desde terraform.tfvars, lo que permite reutilizar la misma plantilla para distintos entornos.
- Comparativa real con Heat: el mismo despliegue realizado con ambas herramientas para evaluar diferencias en usabilidad, idempotencia y flexibilidad.
- Verificación de conectividad y seguridad entre capas.

Tecnologías utilizadas:

- OpenStack 2024.1 (Caracal)
- Terraform 1.14.7
- OpenStack Heat
- HCL (HashiCorp Configuration Language)
- Python OpenStack Client

La conclusión es clara: Terraform gana en modularidad, idempotencia y flexibilidad multi-entorno. Heat tiene su lugar como solución nativa de OpenStack, pero Terraform es la herramienta cuando buscas una plantilla verdaderamente reutilizable.

Como siguiente paso, el objetivo es complementar esta infraestructura con Ansible para el aprovisionamiento de servicios: Nginx, Apache+PHP y MySQL+WordPress sobre las instancias desplegadas.

Cualquier feedback o intercambio de ideas es bienvenido 🙌

#OpenStack #Terraform #Heat #IaC #DevOps #SysAdmin #Cloud #Linux #Automation #Infrastructure #Networking
