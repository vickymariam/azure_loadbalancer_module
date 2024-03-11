resource "azurerm_lb" "this" {
  name                = var.lb_name
  location            = var.location
  resource_group_name = var.resource_group_name

  frontend_ip_configuration {
    name                 = var.frontend_ip_name
    public_ip_address_id = var.public_ip_address_id
  }

}
resource "azurerm_lb_backend_address_pool" "this" {
  for_each        = toset(var.backend_address_pool_names)
  loadbalancer_id = azurerm_lb.this.id
  name            = each.value
}


resource "azurerm_network_interface_backend_address_pool_association" "this" {
  for_each                = var.network_interfaces
  network_interface_id    = each.value.id
  ip_configuration_name   = each.value.ip_configuration.0.name
  backend_address_pool_id = azurerm_lb_backend_address_pool.this[trimprefix(each.value.ip_configuration.0.name, "ip-")].id
}


resource "azurerm_lb_rule" "this" {
  for_each                       = var.lb_rules
  loadbalancer_id                = azurerm_lb.this.id
  name                           = each.value.name
  protocol                       = each.value.protocol
  frontend_port                  = each.value.frontend_port
  backend_port                   = each.value.backend_port
  frontend_ip_configuration_name = each.value.frontend_ip_configuration_name
  backend_address_pool_ids       = [azurerm_lb_backend_address_pool.this[each.key].id]
  probe_id                       = azurerm_lb_probe.this.id
  depends_on                     = [azurerm_lb_probe.this]
}

resource "azurerm_lb_probe" "this" {
  loadbalancer_id = azurerm_lb.this.id
  name            = var.probe_name
  port            = var.port
  depends_on      = [azurerm_lb.this]
}
