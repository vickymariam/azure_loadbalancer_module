variable "resource_group_name" {
  description = "The name of the Azure Resource Group."
  default     = "loadbalancer-demo-rg"
}

variable "location" {
  description = "The Azure region where the resources will be created."
  default     = "eastus2"
}

variable "virtual_network_name" {
  description = "The name of the Azure Virtual Network."
  default     = "demo-network"
}

variable "virtual_network_address_space" {
  description = "The address space for the Azure Virtual Network."
  default     = ["10.0.0.0/16"]
}

variable "address_prefixes" {
  type        = list(string)
  description = " (Required) The address prefixes to use for the subnet."
  default     = ["10.0.2.0/24"]
}
variable "subnet_name" {
  type        = string
  description = "(Required) The name of the subnet. Changing this forces a new resource to be created."
  default     = "demo-sub"

}



variable "public_ip_instances" {
  type = map(object({
    name              = string
    allocation_method = string
  }))
  default = {
    vm1 = {
      name              = "public-ip-vm1"
      allocation_method = "Static"
    }
    vm2 = {
      name              = "public-ip-vm2"
      allocation_method = "Static"
    }
    lb = {
      name              = "public-ip-lb"
      allocation_method = "Static"
    }
  }
}


variable "availability_set" {
  type    = string
  default = "vm-aset"
}


variable "vm_instances" {
  type = map(object({
    name                          = string
    backend_pool_name             = string
    private_ip_address_allocation = string

  }))
  default = {
    vm1 = {
      name                          = "vm1"
      backend_pool_name             = "pool1"
      private_ip_address_allocation = "Dynamic"


    }
    vm2 = {
      name                          = "vm2"
      backend_pool_name             = "pool2"
      private_ip_address_allocation = "Dynamic"
    }
  }
}


variable "nsg" {
  type    = string
  default = "vm-nsg"
}


variable "nsg-web" {
  type = map(object({
    name                       = string
    priority                   = number
    direction                  = string
    access                     = string
    protocol                   = string
    source_address_prefix      = string
    source_port_range          = string
    destination_address_prefix = string
    destination_port_range     = string
  }))
  default = {
    rule1 = {
      name                       = "httptovm"
      priority                   = 100
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_range     = "80"
      source_address_prefix      = "*"
      destination_address_prefix = "10.0.2.0/24"
    }
    rule2 = {
      name                       = "sshtovm"
      priority                   = 110
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_range     = "22"
      source_address_prefix      = "*"
      destination_address_prefix = "10.0.2.0/24"
    }
    rule3 = {
      name                       = "vmtointernet"
      priority                   = 120
      direction                  = "Outbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range          = "8080"
      destination_port_range     = "8080"
      source_address_prefix      = "10.0.2.0/24"
      destination_address_prefix = "*"
    }
  }
}

variable "probe_name" {
  type        = string
  default     = "lp-probe"
  description = "(Required) Specifies the name of the Probe. Changing this forces a new resource to be created."
}

variable "port" {
  type        = string
  default     = "80"
  description = " (Required) Port on which the Probe queries the backend endpoint. Possible values range from 1 to 65535, inclusive"
}


variable "backend_address_pool_names" {
  type    = list(string)
  default = ["pool1", "pool2"]
}
