provider "azurerm" {
    features { 
    }
    subscription_id = "3f310de7-7dd2-4e3d-96bf-bc925e1f96f5"
}

resource "azurerm_resource_group" "main" {
  name     = "rg-firewall-demo"
  location = "East US"
}

resource "azurerm_virtual_network" "main" {
  name                = "vnet-demo"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
}

resource "azurerm_subnet" "main" {
  name                 = "subnet-demo"
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_public_ip" "firewall_pip" {
  name                = "firewall-pip"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_public_ip" "vm_public_ip" {
  name                = "vm-public-ip"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  allocation_method   = "Static"
  sku                 = "Basic"
}


resource "azurerm_firewall_policy" "main" {
  name                = "fw-policy"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
}

resource "azurerm_firewall_policy_rule_collection_group" "example" {
  name               = "fw-policy-rcg"
  firewall_policy_id = azurerm_firewall_policy.main.id
  priority           = 100

  application_rule_collection {
    name     = "block-yahoo"
    priority = 1000
    action   = "Deny"

    rule {
      name              = "deny-yahoo"
      source_addresses  = ["*"]
      destination_fqdns = ["yahoo.com"]

      protocols {
        type = "Http"
        port = 80
      }
      protocols {
        type = "Https"
        port = 443
      }
    }
  }

  application_rule_collection {
    name     = "allow-all"
    priority = 2000
    action   = "Allow"

    rule {
      name              = "allow-all-sites"
      source_addresses  = ["*"]
      destination_fqdns = ["*"]

      protocols {
        type = "Http"
        port = 80
      }
      protocols {
        type = "Https"
        port = 443
      }
    }
  }
    network_rule_collection {
    name     = "allow-dns"
    priority = 300
    action   = "Allow"
    rule {
      name                  = "allow-dns"
      source_addresses      = ["*"]
      destination_addresses = ["*"]
      destination_ports     = ["53"]
      protocols             = ["UDP", "TCP"]
    }
  }
  network_rule_collection {
  name     = "allow-ssh"
  priority = 500
  action   = "Allow"

  rule {
    name                  = "allow-ssh-from-internet"
    source_addresses      = ["*"]
    destination_ports     = ["22"]
    #destination_addresses = [azurerm_network_interface.vm_nic.azurerm_public_ip]
    destination_addresses = [azurerm_public_ip.vm_public_ip.ip_address]
    protocols             = ["TCP"]
  }
}

}




resource "azurerm_firewall" "main" {
  name                = "demo-firewall"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  sku_name            = "AZFW_VNet"
  sku_tier            = "Standard"

  ip_configuration {
    name                 = "firewall-ipconfig"
    subnet_id            = azurerm_subnet.firewall_subnet.id
    public_ip_address_id = azurerm_public_ip.firewall_pip.id
  }

  firewall_policy_id = azurerm_firewall_policy.main.id
}

resource "azurerm_subnet" "firewall_subnet" {
  name                 = "AzureFirewallSubnet"
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = ["10.0.2.0/24"]
}

resource "azurerm_network_interface" "vm_nic" {
  name                = "vmnic"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.main.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.vm_public_ip.id
  }
}

resource "azurerm_linux_virtual_machine" "ubuntu_vm" {
  name                = "ubuntu-vm"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  size                = "Standard_B1s"
  admin_username      = "azureuser"
  network_interface_ids = [
    azurerm_network_interface.vm_nic.id,
  ]
  disable_password_authentication = false
  admin_password = "Azure12345678!"

#   source_image_reference {
#     publisher = "Canonical"
#     offer     = "0001-com-ubuntu-server-jammy"
#     sku       = "24_04-lts"
#     version   = "latest"
#   }
    # source_image_reference {
    # publisher = "Canonical"
    # offer     = "0001-com-ubuntu-server-jammy"
    # sku       = "24_04-lts-gen2"
    # version   = "latest"
    # }
source_image_reference {
  publisher = "Canonical"
  offer     = "0001-com-ubuntu-server-jammy"
  sku       = "22_04-lts-gen2"
  version   = "latest"
}

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }
}

resource "azurerm_route_table" "main" {
  name                = "rt-main"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name

  route {
    name                   = "default-via-firewall"
    address_prefix         = "0.0.0.0/0"
    next_hop_type          = "VirtualAppliance"
    next_hop_in_ip_address = azurerm_firewall.main.ip_configuration[0].private_ip_address
  }
}

resource "azurerm_subnet_route_table_association" "main" {
  subnet_id      = azurerm_subnet.main.id
  route_table_id = azurerm_route_table.main.id
}


resource "azurerm_network_security_group" "vm_nsg" {
  name                = "vm-nsg"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name

  security_rule {
    name                       = "Allow-SSH-Inbound"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

resource "azurerm_network_interface_security_group_association" "nic_nsg_assoc" {
  network_interface_id      = azurerm_network_interface.vm_nic.id
  network_security_group_id = azurerm_network_security_group.vm_nsg.id
}
