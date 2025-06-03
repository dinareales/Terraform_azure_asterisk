# ☎️ Despliegue de Asterisk en Azure con Terraform

Este proyecto despliega una máquina virtual en Azure con Asterisk preinstalado, utilizando una imagen del Marketplace, optimizado para la capa gratuita de Azure.

---

## 📦 Requisitos

- ✅ Cuenta de Azure con CLI configurado (`az login`)
- ✅ Terraform versión 1.0 o superior
- ✅ Credenciales válidas de Azure
- ✅ Términos del Marketplace aceptados

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

1. **Inicializar el entorno Terraform:**

   ```bash
   terraform init
   ```

2. **Aplicar la infraestructura con tu contraseña segura:**

   ```bash
   terraform apply -var="admin_password=TuContraseñaSegura123!"
   ```

3. **Opcional:** Aceptar manualmente los términos del Marketplace si ves errores:

   ```bash
   az vm image terms accept \
     --publisher "pcloudhosting" \
     --offer "asterisk" \
     --plan "asterisk-22-3-0-free-support-on-opensuse-15-6"
   ```

---

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
- Apagado automático 19:00 UTC

---

## ℹ️ Soporte y configuración Asterisk

La imagen preconfigurada es publicada por `pcloudhosting`.

Consulta su documentación oficial en el Marketplace de Azure para credenciales, interfaz web (si aplica) y configuración por defecto.

---
