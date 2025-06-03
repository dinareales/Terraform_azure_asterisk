terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }
}

provider "azurerm" {
  features {}
}

# Grupo de recursos
resource "azurerm_resource_group" "asterisk_rg" {
  name     = var.resource_group_name
  location = var.location
  tags = {
    environment = "free-tier"
    project     = "asterisk-voip"
  }
}

# Red y subred
resource "azurerm_virtual_network" "asterisk_vnet" {
  name                = "asterisk-vnet"
  address_space       = ["10.0.0.0/16"]
  location            = var.location
  resource_group_name = azurerm_resource_group.asterisk_rg.name
}

resource "azurerm_subnet" "asterisk_subnet" {
  name                 = "asterisk-subnet"
  resource_group_name  = azurerm_resource_group.asterisk_rg.name
  virtual_network_name = azurerm_virtual_network.asterisk_vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}

# IP pública
resource "azurerm_public_ip" "asterisk_public_ip" {
  name                = "asterisk-public-ip"
  location            = var.location
  resource_group_name = azurerm_resource_group.asterisk_rg.name
  allocation_method   = "Dynamic"
  domain_name_label   = "asterisk-${lower(replace(var.resource_group_name, "-", ""))}"
  tags = {
    environment = "free-tier"
  }
}

# NSG y reglas
resource "azurerm_network_security_group" "asterisk_nsg" {
  name                = "asterisk-nsg"
  location            = var.location
  resource_group_name = azurerm_resource_group.asterisk_rg.name

  security_rule {
    name                       = "SSH"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "SIP-UDP"
    priority                   = 1002
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Udp"
    source_port_range          = "*"
    destination_port_range     = "5060"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "SIP-TCP"
    priority                   = 1003
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "5060"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "RTP"
    priority                   = 1004
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Udp"
    source_port_range          = "*"
    destination_port_range     = "10000-20000"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

# NIC y asociación NSG
resource "azurerm_network_interface" "asterisk_nic" {
  name                = "asterisk-nic"
  location            = var.location
  resource_group_name = azurerm_resource_group.asterisk_rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.asterisk_subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.asterisk_public_ip.id
  }
}

resource "azurerm_network_interface_security_group_association" "asterisk_nic_nsg_association" {
  network_interface_id      = azurerm_network_interface.asterisk_nic.id
  network_security_group_id = azurerm_network_security_group.asterisk_nsg.id
}

# Script de instalación de Asterisk
locals {
  custom_data = <<-EOF
    #!/bin/bash
    # (Todo el contenido del script que ya tienes aquí)
  EOF
}

# Máquina virtual
resource "azurerm_linux_virtual_machine" "asterisk_vm" {
  name                = "asterisk-vm"
  resource_group_name = azurerm_resource_group.asterisk_rg.name
  location            = var.location
  size                = var.vm_size
  admin_username      = var.admin_username
  admin_password      = var.admin_password
  disable_password_authentication = false

  network_interface_ids = [
    azurerm_network_interface.asterisk_nic.id,
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
    disk_size_gb         = 30
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }

  custom_data = base64encode(local.custom_data)

  tags = {
    environment = "free-tier"
    application = "asterisk"
  }
}

# Apagado automático
resource "azurerm_dev_test_global_vm_shutdown_schedule" "asterisk_shutdown" {
  virtual_machine_id    = azurerm_linux_virtual_machine.asterisk_vm.id
  location              = var.location
  enabled               = true
  daily_recurrence_time = "1900"
  timezone              = "UTC"

  notification_settings {
    enabled = false
  }
}
