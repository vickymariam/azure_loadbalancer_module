# module "<module_name>" {
#   source              = "app.terraform.io/perizer/module_name/azurerm"
#   version             = "0.1.0"
# }

resource "azurerm_resource_group" "this" {
  name     = var.resource_group_name
  location = var.location
}

resource "azurerm_virtual_network" "this" {
  name                = var.virtual_network_name
  address_space       = var.virtual_network_address_space
  location            = var.location
  resource_group_name = var.resource_group_name
  depends_on          = [azurerm_resource_group.this]
}

resource "azurerm_subnet" "this" {
  name                 = var.subnet_name
  resource_group_name  = var.resource_group_name
  virtual_network_name = var.virtual_network_name
  address_prefixes     = var.address_prefixes
  depends_on           = [azurerm_virtual_network.this]
}


resource "azurerm_public_ip" "this" {
  for_each = var.public_ip_instances

  name                = each.value.name
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
  allocation_method   = each.value.allocation_method
  depends_on          = [azurerm_subnet.this]
}

resource "azurerm_network_interface" "this" {
  for_each            = var.vm_instances
  name                = "nic-${each.value.name}"
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name

  ip_configuration {
    name                          = "ip-${each.value.backend_pool_name}"
    subnet_id                     = azurerm_subnet.this.id
    private_ip_address_allocation = each.value.private_ip_address_allocation
    public_ip_address_id          = azurerm_public_ip.this[each.key].id
  }
}

resource "azurerm_availability_set" "this" {
  name                = var.availability_set
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
}



resource "azurerm_linux_virtual_machine" "this" {
  for_each                        = var.vm_instances
  name                            = each.value.name
  location                        = azurerm_resource_group.this.location
  resource_group_name             = azurerm_resource_group.this.name
  network_interface_ids           = [azurerm_network_interface.this[each.key].id]
  size                            = "Standard_B1s"
  admin_username                  = "adminuser"
  admin_password                  = "Password1234!"
  disable_password_authentication = "false"
  availability_set_id             = azurerm_availability_set.this.id

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-focal"
    sku       = "20_04-lts"
    version   = "latest"
  }
}


module "lb" {
  source = "../"

  lb_name             = "loadbalaner"
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name

  frontend_ip_name     = "primary"
  public_ip_address_id = azurerm_public_ip.this["lb"].id


  backend_address_pool_names = var.backend_address_pool_names



  network_interfaces = { for name, nic in azurerm_network_interface.this : name => nic }


  lb_rules = {
    pool1 = {
      name                           = "rule1"
      frontend_ip_configuration_name = "primary"
      frontend_port                  = 80
      backend_port                   = 80
      protocol                       = "Tcp"
    }
    pool2 = {
      name                           = "rule2"
      frontend_ip_configuration_name = "primary"
      frontend_port                  = 8080
      backend_port                   = 8080
      protocol                       = "Tcp"
    }
  }

  probe_name = var.probe_name
  port       = var.port

}


resource "azurerm_network_security_group" "this" {
  name                = var.nsg
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
}

resource "azurerm_network_security_rule" "this" {
  for_each                    = var.nsg-web
  name                        = each.value.name
  priority                    = each.value.priority
  direction                   = each.value.direction
  access                      = each.value.access
  protocol                    = each.value.protocol
  source_address_prefix       = each.value.source_address_prefix
  source_port_range           = each.value.source_port_range
  destination_address_prefix  = each.value.destination_address_prefix
  destination_port_range      = each.value.destination_port_range
  network_security_group_name = azurerm_network_security_group.this.name
  resource_group_name         = azurerm_resource_group.this.name
}

resource "azurerm_subnet_network_security_group_association" "example" {
  subnet_id                 = azurerm_subnet.this.id
  network_security_group_id = azurerm_network_security_group.this.id
}



# output "nic" {
#   value = module.lb.nic
# }







