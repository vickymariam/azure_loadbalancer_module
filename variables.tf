variable "lb_name" {
  type        = string
  description = " (Required) Specifies the name of the Load Balancer. Changing this forces a new resource to be created."
}

variable "location" {
  type        = string
  description = "(Required) Specifies the supported Azure Region where the Load Balancer should be created. Changing this forces a new resource to be created."
}

variable "resource_group_name" {
  type        = string
  description = " (Required) The name of the Resource Group in which to create the Load Balancer. Changing this forces a new resource to be created."
}
variable "frontend_ip_name" {
  type        = string
  description = " (Required) Specifies the name of the frontend IP configuration."
}

variable "public_ip_address_id" {
  type        = string
  description = "(Optional) The ID of a Public IP Address which should be associated with the Load Balancer."
}


variable "network_interfaces" {
  description = "(Required) The name of the Network Interface. Changing this forces a new resource to be created."
}


variable "backend_address_pool_names" {
  type        = list(string)
  description = " (Required) Specifies the name of the Backend Address Pool. Changing this forces a new resource to be created."
}


variable "probe_name" {
  type        = string
  description = "(Required) Specifies the name of the Probe. Changing this forces a new resource to be created."
}

variable "port" {
  type        = string
  description = " (Required) Port on which the Probe queries the backend endpoint. Possible values range from 1 to 65535, inclusive"
}


variable "lb_rules" {
  type = map(object({
    name                           = string
    frontend_ip_configuration_name = string
    frontend_port                  = number
    backend_port                   = number
    protocol                       = string
  }))
}
