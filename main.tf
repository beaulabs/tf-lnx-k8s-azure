# This Terraform code is used to create a simple K8s environment for training and demo purposes.
# Initially due to permission restrictions you will need to authenticate Terraform via the Azure CLI
# command `az login` before running the codebase. As this is version "early on" we'll make adjustements
# to get an Azure Service Principal in place with tighter permission controls. 

# NOTE: In 'null_resource' to push commands to Azure as well as the VMs this codebase is using PowerShell 5.1.
# If you want to use Powershell 7 (pwsh) you can choose to 1) install it and then 2) change the code to be
# 'pwsh' instead of 'Powershell'.

# REQUIREMENTS INSTALLED ON LOCALHOST: 
# Powershell
# Azure Command Line (az)
  
# Main.tf Code Version: 1.0
# Creation Date: 15 Jul 2022
# Update/Refresh Date: 04 Apr 2024
# Author: Beaulabs

# Set the Azure Provider source and version

terraform {
    required_providers {
        azurerm = {
            source = "hashicorp/azurerm"
            version = "~> 4.25.0"
        }
    }
}

# Set up data resource for use in build. 
# NOTE - UNCOMMENT THE APPROPRIATE CODE BLOCK BASED ON YOUR OS

# WINDOWS

# data "external" "my_source_ip" {
#   program = ["powershell", ".\\scripts\\myip.ps1"]
# }

# LINUX / MACOS

data "external" "my_source_ip" {
  program = ["/bin/bash", "./scripts/myip.sh"]
}

# Set up some locals to ease the duplication effort

# Locals - for tagging
locals {
  resource_tags = {
    envname = var.env_name
    envteam = var.env_team
    envowner = var.env_owner
  }
}

# Locals - create list of objects for multiple different virtual machine type build out
# found in variables.tf block 'variable "server_configuration"'
locals {
  serverconfig = [
    for server in var.server_configuration : [
      for i in range(1, server.num_of_servers+1) : {
        name = "${server.server_purpose}-${i}"
        size = server.size
        type = server.type
        evictpolicy = server.evictpolicy   
      }
    ]
  ]
}

# Locals - flatten the list of ojbect to single list of the serverconfig to feed 
# into for_each loop creating virtual machines
locals {
  server_instance = flatten(local.serverconfig)
}

# Configure Azure Provider

provider "azurerm" {
    features{}
}

# Create resource group to run the us_sa_k8s elements

resource "azurerm_resource_group" "us_sa_k8s_rg" {
  name = var.resource_group_name
  location = var.resource_group_location

  tags = local.resource_tags
}

# Create the required network components

resource "azurerm_virtual_network" "us_sa_k8s_net" {
  name = var.network_name
  address_space = var.network_cidr
  resource_group_name = azurerm_resource_group.us_sa_k8s_rg.name
  location = azurerm_resource_group.us_sa_k8s_rg.location
}

resource "azurerm_subnet" "us_sa_k8s_subnet" {
  name = var.subnet_name
  virtual_network_name = azurerm_virtual_network.us_sa_k8s_net.name
  resource_group_name = azurerm_resource_group.us_sa_k8s_rg.name
  address_prefixes = var.subnet_address_space
  service_endpoints = ["Microsoft.Storage"]
}

# Set the network security group rules

resource "azurerm_network_security_group" "us_sa_k8s_nsg" {
  name = var.nsg_name
  resource_group_name = azurerm_resource_group.us_sa_k8s_rg.name
  location = azurerm_resource_group.us_sa_k8s_rg.location

  security_rule {
    name = "allow-rdp-known-external-inbound"
    description = "Allow RDP access from known external"
    priority = 100
    direction = "Inbound"
    access = "Allow"
    protocol = "Tcp"
    source_port_range = "*"
    destination_port_range = "3389"
    source_address_prefixes = [format("%s/%s", data.external.my_source_ip.result["ip"],32)]
    destination_address_prefix = "*"
  }

  security_rule {
    name = "allow-spa-known-external-inbound"
    description = "Allow SPA access for demo"
    priority = 101
    direction = "Inbound"
    access = "Allow"
    protocol = "Tcp"
    source_port_range = "*"
    destination_port_range = "3000"
    source_address_prefixes = [format("%s/%s", data.external.my_source_ip.result["ip"],32)]
    destination_address_prefix = "*"
  }

  security_rule {
    name = "allow-ssh-known-external-inbound"
    description = "Allow SSH access from known external"
    priority = 102
    direction = "Inbound"
    access = "Allow"
    protocol = "Tcp"
    source_port_range = "*"
    destination_port_range = "22"
    source_address_prefixes = [format("%s/%s", data.external.my_source_ip.result["ip"],32)]
    destination_address_prefix = "*"
  }

  security_rule {
    name = "allow-apigw-known-external-inbound"
    description = "Allow APIGW access from known external"
    priority = 103
    direction = "Inbound"
    access = "Allow"
    protocol = "Tcp"
    source_port_range = "*"
    destination_port_range = "8200"
    source_address_prefixes = [format("%s/%s", data.external.my_source_ip.result["ip"],32)]
    destination_address_prefix = "*"
  }

  tags = local.resource_tags

}

# Deploy Windows VMs

resource "azurerm_public_ip" "us_sa_k8s_public_ip" {
  for_each = {for server in local.server_instance: server.name => server}
  name = "${each.value.name}-pubip"
  resource_group_name = azurerm_resource_group.us_sa_k8s_rg.name
  location = azurerm_resource_group.us_sa_k8s_rg.location
  allocation_method = "Dynamic"
  sku = "Basic"
}

resource "azurerm_network_interface" "us_sa_k8s_nic" {
  for_each = {for server in local.server_instance: server.name => server}
  name = "${each.value.name}-nic"
  resource_group_name = azurerm_resource_group.us_sa_k8s_rg.name
  location = azurerm_resource_group.us_sa_k8s_rg.location

  ip_configuration {
    name = "internal"
    subnet_id = azurerm_subnet.us_sa_k8s_subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id = azurerm_public_ip.us_sa_k8s_public_ip[each.value.name].id
  }
}

resource "azurerm_network_interface_security_group_association" "us_sa_k8s_nic_nsg" {
  for_each = {for server in local.server_instance: server.name => server}
  network_interface_id = azurerm_network_interface.us_sa_k8s_nic[each.value.name].id
  network_security_group_id = azurerm_network_security_group.us_sa_k8s_nsg.id
}

resource "azurerm_linux_virtual_machine" "us_sa_k8s_lnxservers" {
  for_each = {for server in local.server_instance: server.name => server }
  resource_group_name = azurerm_resource_group.us_sa_k8s_rg.name
  location = azurerm_resource_group.us_sa_k8s_rg.location
  name = each.value.name
  size = each.value.size
  priority = each.value.type
  #eviction_policy = each.value.evictpolicy
  admin_username = "sademo"
  network_interface_ids = [
    azurerm_network_interface.us_sa_k8s_nic[each.value.name].id,
  ]

admin_ssh_key {
  username = "sademo"
  public_key = file("~/.ssh/az_id_rsa.pub")
}

  os_disk {
    caching = "ReadWrite"
    storage_account_type = "StandardSSD_LRS"
    disk_size_gb = 100 
  }

  source_image_reference {
    publisher = "Canonical"
    offer = "ubuntu-24_04-lts"
    sku = "server"
    version = "24.04.202502210"
  }

  tags = local.resource_tags
}




