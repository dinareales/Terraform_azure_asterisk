output "vm_public_ip" {
  value = azurerm_public_ip.public_ip.ip_address
}

output "access_url" {
  value = "http://${azurerm_public_ip.public_ip.ip_address}"
}
