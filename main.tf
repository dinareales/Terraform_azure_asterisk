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

resource "azurerm_resource_group" "asterisk_rg" {
  name     = var.resource_group_name
  location = var.location
  tags = {
    environment = "free-tier"
    project     = "asterisk-voip"
  }
}

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

resource "azurerm_network_security_group" "asterisk_nsg" {
  name                = "asterisk-nsg"
  location            = var.location
  resource_group_name = azurerm_resource_group.asterisk_rg.name

  dynamic "security_rule" {
    for_each = [
      { name = "SSH",     port = "22",    protocol = "Tcp", priority = 1001 },
      { name = "SIP-UDP", port = "5060",  protocol = "Udp", priority = 1002 },
      { name = "SIP-TCP", port = "5060",  protocol = "Tcp", priority = 1003 },
      { name = "RTP",     port = "10000-20000", protocol = "Udp", priority = 1004 },
      { name = "HTTP",    port = "80",    protocol = "Tcp", priority = 1005 },
      { name = "HTTPS",   port = "443",   protocol = "Tcp", priority = 1006 },
    ]
    content {
      name                       = security_rule.value.name
      priority                   = security_rule.value.priority
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = security_rule.value.protocol
      source_port_range          = "*"
      destination_port_range     = security_rule.value.port
      source_address_prefix      = "*"
      destination_address_prefix = "*"
    }
  }

  tags = {
    environment = "free-tier"
  }
}

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

resource "azurerm_marketplace_agreement" "asterisk_agreement" {
  publisher = "pcloudhosting"
  offer     = "asterisk"
  plan      = "asterisk-22-3-0-free-support-on-opensuse-15-6"
}

resource "azurerm_linux_virtual_machine" "asterisk_vm" {
  name                            = "asterisk-vm"
  resource_group_name             = azurerm_resource_group.asterisk_rg.name
  location                        = var.location
  size                            = var.vm_size
  admin_username                  = var.admin_username
  admin_password                  = var.admin_password
  disable_password_authentication = false

  network_interface_ids = [azurerm_network_interface.asterisk_nic.id]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
    disk_size_gb         = 30
  }

  plan {
    name      = "asterisk-22-3-0-free-support-on-opensuse-15-6"
    product   = "asterisk"
    publisher = "pcloudhosting"
  }

  source_image_reference {
    publisher = "pcloudhosting"
    offer     = "asterisk"
    sku       = "asterisk-22-3-0-free-support-on-opensuse-15-6"
    version   = "latest"
  }

  tags = {
    environment = "free-tier"
    application = "asterisk"
  }

  depends_on = [azurerm_marketplace_agreement.asterisk_agreement]
}

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
