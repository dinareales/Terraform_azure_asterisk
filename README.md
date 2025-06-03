# ☎️ Asterisk en Azure con Terraform (Capa Gratuita)

Este proyecto despliega una máquina virtual en Azure con Asterisk instalado automáticamente mediante `cloud-init`.

## 📦 Requisitos

- [Terraform >= 1.3](https://www.terraform.io/downloads)
- Cuenta de Azure con CLI configurado (`az login`)
- Permisos para crear recursos

## 🚀 Despliegue

```bash
terraform init
terraform apply -var="admin_password=TuPasswordSeguroAqui"
