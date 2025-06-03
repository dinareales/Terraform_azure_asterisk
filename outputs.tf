output "public_ip_address" {
  value       = azurerm_public_ip.asterisk_public_ip.ip_address
  description = "La dirección IP pública de la VM de Asterisk"
}

output "public_fqdn" {
  value       = azurerm_public_ip.asterisk_public_ip.fqdn
  description = "El FQDN de la VM de Asterisk"
}

output "ssh_connection" {
  value       = "ssh ${var.admin_username}@${azurerm_public_ip.asterisk_public_ip.fqdn}"
  description = "Comando para conectarse por SSH a la VM"
}

output "asterisk_extensions" {
  value       = "Extensiones configuradas: 1000 (password1000) y 1001 (password1001)"
  description = "Información de las extensiones SIP configuradas"
}
