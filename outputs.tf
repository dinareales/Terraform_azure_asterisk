output "public_ip_address" {
  value       = azurerm_public_ip.asterisk_public_ip.ip_address
  description = "La dirección IP pública de la VM de Asterisk"
  depends_on  = [azurerm_linux_virtual_machine.asterisk_vm]
}

output "public_fqdn" {
  value       = azurerm_public_ip.asterisk_public_ip.fqdn
  description = "El FQDN de la VM de Asterisk"
}

output "ssh_connection" {
  value       = "ssh ${var.admin_username}@${azurerm_public_ip.asterisk_public_ip.fqdn}"
  description = "Comando para conectarse por SSH a la VM"
}

output "asterisk_info" {
  value       = "Asterisk 22.3.0 está preinstalado en esta VM. Consulta la documentación de pcloudhosting para las credenciales predeterminadas y configuración."
  description = "Información sobre Asterisk preinstalado"
}
