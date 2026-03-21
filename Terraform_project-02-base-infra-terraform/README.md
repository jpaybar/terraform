# Terraform vs Heat: Deploying a 3-Tier Infrastructure on OpenStack

###### By Juan Manuel Payán / jpaybar

st4rt.fr0m.scr4tch@gmail.com

---

## 📌 Overview

This project demonstrates the automated deployment of a **3-tier network infrastructure** on OpenStack using **Terraform**, and compares it with the same deployment using **OpenStack Heat**.

The infrastructure consists of three isolated networks, three virtual machines, routers, security groups, and a floating IP — all deployed and managed as code.

The goal is to showcase the advantages of Terraform over Heat for infrastructure automation, focusing on modularity, reusability, and idempotency.

---

## 🧪 Environment

### 🖥️ Host System

- OS: Ubuntu 24.04
- CPU: AMD Ryzen 5 3600 (6 cores)
- RAM: 32 GB
- Storage: NVMe SSD

### ☁️ OpenStack

- Platform: OpenStack 2024.1 (Caracal)
- Deployment: Sunbeam (single-node on KVM)

### 🔧 Tools

- Terraform: 1.14.7
- OpenStack Terraform Provider: ~> 1.54
- OpenStack Heat: included in OpenStack 2024.1 (Caracal)
- Python OpenStack Client: latest

---

## 🏗️ Architecture

The infrastructure follows a classic **3-tier architecture**:

| Tier        | Server  | Network               | Role                         |
| ----------- | ------- | --------------------- | ---------------------------- |
| Frontend    | server1 | net1 (192.168.1.0/24) | Nginx reverse proxy (public) |
| Application | server2 | net2 (192.168.2.0/24) | Apache + PHP (internal)      |
| Database    | server3 | net3 (192.168.3.0/24) | MySQL (internal)             |

```
Internet
    |
    | (Floating IP)
    |
[ server1 - net1 ] ── Nginx reverse proxy
    |
    | (192.168.1.0/24 → 192.168.2.0/24)
    |
[ server2 - net2 ] ── Apache + PHP
    |
    | (192.168.2.0/24 → 192.168.3.0/24)
    |
[ server3 - net3 ] ── MySQL
```

### 🔒 Security Groups

- **sg_server1**: SSH, ICMP, HTTP from `0.0.0.0/0` (public)
- **sg_server2**: SSH, ICMP, HTTP from `192.168.1.0/24` only
- **sg_server3**: SSH, ICMP, MySQL (3306) from `192.168.2.0/24` only

---

## 🔧 What is Terraform?

[Terraform](https://www.terraform.io/) is an open-source **Infrastructure as Code (IaC)** tool developed by HashiCorp. It allows you to define infrastructure in a declarative language (HCL) and manage it across multiple cloud providers.

Key features:

- **Multi-cloud**: AWS, GCP, Azure, OpenStack, and more
- **Modular**: reusable modules for any infrastructure component
- **Idempotent**: apply the same plan multiple times safely
- **State-aware**: tracks the real state of infrastructure via `terraform.tfstate`

---

## 🔥 What is Heat?

[OpenStack Heat](https://docs.openstack.org/heat/latest/) is the **native orchestration service** of OpenStack. It uses YAML-based templates to define and deploy cloud resources within an OpenStack environment.

Key features:

- **Native OpenStack**: deeply integrated with all OpenStack services
- **Stack-based**: resources are grouped into stacks
- **Template-driven**: uses HOT (Heat Orchestration Template) format

---

## 📂 Project Structure

The Terraform project is organized into **independent, reusable modules**, one per infrastructure component:

```
project-02-base-infra-terraform/
├── main.tf                    # Root module - calls all child modules
├── variables.tf               # Root variable declarations
├── terraform.tfvars           # Variable values (dev environment)
├── outputs.tf                 # Root outputs (IPs, IDs)
├── providers.tf               # OpenStack provider configuration
└── modules/
    ├── networks/              # Networks and subnets
    ├── routers/               # Routers and static routes
    ├── security-groups/       # Security groups and rules
    ├── servers/               # Ports and compute instances
    └── floating-ips/          # Floating IP allocation and association
```

![Project Structure](pics/7_Proyecto_despligue_terraform.png)

### 💡 Key Design Decision: `terraform.tfvars`

All values (CIDRs, names, IPs, DNS, next hops) are defined in `terraform.tfvars` and flow through `variables.tf` into each module. No hardcoded values exist in any module.

This makes the project a **true reusable template**: to deploy a different environment, just use a different `.tfvars` file:

```bash
terraform apply -var-file="terraform-pro.tfvars"
terraform apply -var-file="terraform-staging.tfvars"
```

---

## 🚀 Deployment with Terraform

### Prerequisites

- OpenStack credentials configured in `~/.config/openstack/clouds.yaml`
- Terraform 1.14.7 installed
- SSH keypair available at `~/.ssh/id_rsa.pub`

### Step 1 — Empty topology

Before deployment, the OpenStack network topology is empty:

![Empty topology](pics/0_Topologia_red_vacia.png)

### Step 2 — Initialize Terraform

```bash
terraform init
```

![Terraform init](pics/1_Terraform_init.png)

### Step 3 — Review the plan

```bash
terraform plan
```

![Terraform plan](pics/2_Terraform_plan.png)

### Step 4 — Apply the infrastructure

```bash
terraform apply
```

![Terraform apply](pics/3_Terraform_apply.png)

### Step 5 — Network topology after deployment

![Network topology](pics/4_Topologia_red_completada.png)

### Step 6 — Check outputs

```bash
terraform output
```

![Terraform output](pics/5_Terraform_output.png)

### Step 7 — Verify connectivity

```bash
ssh ubuntu@<floating_ip>
ping -c4 <server2_ip>
```

![Connectivity verification](pics/6_ping_srv1_srv2.png)

### Destroy the infrastructure

```bash
terraform destroy
```

![Terraform destroy](pics/8_Terraform_destroy.png)

---

## 🔥 Deployment with Heat

The same infrastructure can be deployed using OpenStack Heat. However, some additional steps are required before running the Heat commands:

```bash
# Load OpenStack credentials (required every new terminal session)
source admin-openrc

# Check existing stacks
openstack stack list

# Deploy the stack
openstack stack create -t main.yaml test-stack

# Show stack details
openstack stack show test-stack
```

![Heat deployment](pics/9_Despligue_heat.png)

![Heat deployment OK](pics/10_Despliegue_heat_OK.png)

---

## ⚖️ Terraform vs Heat: Comparison

| Feature               | Terraform                                             | Heat                                                        |
| --------------------- | ----------------------------------------------------- | ----------------------------------------------------------- |
| **Scope**             | Multi-cloud (AWS, GCP, Azure, OpenStack...)           | OpenStack only                                              |
| **Language**          | HCL (HashiCorp Configuration Language)                | YAML (HOT format)                                           |
| **Modularity**        | Native modules, fully reusable                        | Limited, monolithic templates                               |
| **State management**  | `terraform.tfstate` tracks real state                 | Stack state managed by Heat API                             |
| **Idempotency**       | Full — re-run safely at any time                      | Partial — failures require `stack-update` or `stack-delete` |
| **Credentials**       | `clouds.yaml` — configured once                       | `openrc` — must be sourced every session                    |
| **Failure recovery**  | Re-run `terraform apply`, continues where it left off | Must delete/recreate the stack                              |
| **Multi-environment** | `-var-file` for dev/staging/pro                       | Separate template files                                     |
| **Community**         | Huge ecosystem, thousands of providers                | OpenStack-specific                                          |

---

## 🧠 Key Concepts

- **Idempotency**: Run `terraform apply` multiple times — Terraform only changes what is different. With Heat, a failed stack deployment requires manual intervention.

- **True modularity**: Each infrastructure component (networks, routers, security groups, servers) lives in its own module with its own `variables.tf`. Change one without touching the others.

- **Single source of truth**: All values flow from `terraform.tfvars`. To create a production environment with different CIDRs and server names, just create `terraform-pro.tfvars`.

- **Stateful firewall**: Security groups in OpenStack are stateful — return traffic is automatically allowed for established connections. No need for explicit egress rules.

---

## 📚 Official Documentation

- 🔗 Terraform: https://developer.hashicorp.com/terraform/docs
- 🔗 OpenStack Terraform Provider: https://registry.terraform.io/providers/terraform-provider-openstack/openstack/latest/docs
- 🔗 OpenStack Heat: https://docs.openstack.org/heat/latest/

---

## Author Information

Juan Manuel Payán Barea
Systems Administrator | SysOps | IT Infrastructure

st4rt.fr0m.scr4tch@gmail.com

GitHub: https://github.com/jpaybar
LinkedIn: https://es.linkedin.com/in/juanmanuelpayan
