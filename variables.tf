variable "resource_group_name" {
  description = "Nombre del grupo de recursos"
  default     = "asterisk-free-rg"
}

variable "location" {
  description = "Ubicación de Azure para los recursos"
  default     = "eastus"
}

variable "admin_username" {
  description = "Nombre de usuario para la VM"
  default     = "azureuser"
}

variable "admin_password" {
  description = "Contraseña para la VM (debe cumplir requisitos de complejidad de Azure)"
  sensitive   = true
}

variable "vm_size" {
  description = "Tamaño de la VM (optimizado para capa gratuita)"
  default     = "Standard_B1s"
}
