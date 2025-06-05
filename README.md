# ☎️ Despliegue de Asterisk en Azure con Terraform

Este proyecto despliega una máquina virtual en Azure con Asterisk.

---

## 📦 Requisitos

- ✅ Cuenta de Azure con CLI configurado (`az login`)
- ✅ Terraform versión 1.0 o superior
- ✅ Credenciales válidas de Azure
   
---

## 📁 Estructura del Proyecto

```
terraform_asterisk_azure/
├── main_marketplace.tf       # Recursos principales (VM, red, NSG, etc.)
├── variables.tf              # Variables configurables
├── outputs.tf                # Valores de salida (IP, SSH, info)
└── README_marketplace.md     # Esta documentación
```

---

## ⚙️ Uso
## Pasos

```bash
terraform init
terraform validate
terraform plan -out=tfplan
terraform apply tfplan
``` 
## Cargar el script directamente en la VM con SCP
Desde tu máquina local:

```bash
scp -i ~/.ssh/id_rsa install_asterisk.sh azureuser@52.226.133.205:~
```
Luego, dentro de la VM:

```bash
chmod +x install_asterisk.sh
sudo ./install_asterisk.sh
```

## 🔐 Acceso SSH

Una vez desplegada la VM, conecta usando:

```bash
ssh azureuser@<fqdn-o-ip>
```

Reemplaza `<fqdn-o-ip>` por la IP pública o FQDN mostrado en los outputs de Terraform.

---

## 🧪 Verificación

Verifica que Asterisk esté activo:

```bash
sudo systemctl status asterisk
```

Entra a la consola:

```bash
sudo asterisk -rvvv
```

---

## 🧹 Limpieza de Recursos

Para evitar cargos innecesarios, destruye la infraestructura cuando no la necesites:

```bash
terraform destroy -auto-approve
```

---

## 💰 Optimización de Costos

- VM B1s (~$9/mes)
- IP dinámica (ahorra costos)
- Disco estándar (`Standard_LRS`)

---

