# This is the variables file to set descriptions and default values for the Incredibuild v10 environment.
# Note: Yes, you can use an additional .tfvars file for high level variables, but for simplicity we'll
# just code define and initialize the variables here. Later if we want we can expand this...but this is
# for demo and training purposes only. 
#
# The complimenting 'machines.tfvars' file is separate because we want to loop through and set specific
# components for the servers to build (eg. name of server and alternate size of VMs).data

# TAGS
variable "env_name" {
    description = "Sets the environment name for locals tag"
    default = "demo/training"
}

variable "env_team" {
    description = "Sets the environment team for locals tag"
    default = "SA"
}

variable "env_owner" {
    description = "Sets the owner for locals tag"
    default = "beau"
}

# RESOURCE GROUP

variable "resource_group_name" {
    description = "Sets the default resource group to build the elements into"
    default = "us-sa-k8s-rg"
}

variable "resource_group_location" {
    description = "Which region you want to run the resource group in"
    default = "East US 2"
}

# NETWORK RELATED

variable "network_name" {
    description = "Sets the network name for resource traffic"
    default = "us-sa-k8s-net"
}

variable "network_cidr" {
    description = "CIDR to use for network"
    default = ["172.16.0.0/16"]
}

variable "subnet_name" {
    description = "Sets the subnet name for resource traffic"
    default = "us-sa-k8s-subnet"
}

variable "subnet_address_space"{
    description = "Designate the address space from CIDR to use for subnet"
    default = ["172.16.1.0/24"]
}

# SECURITY RELATED
variable "nsg_name"{
    description = "Set the name of the network security group"
    default = "us-sa-k8s-nsg"
}



# VM RELATED - NOTE - For "type" use "Spot" or "Regular" for virtual machine type to be created
# Note: For automation purposes in the future, leave the first entry as the Coordinator.
# IMPORTANT: If you choose 'Regular' as type you must comment out 'eviction_policy' under 'azurerm_windows_virtual_machine' in main.tf
variable "server_configuration" {
    description = "List/dictionary of server configurations desired to be deployed"
    default = [ 
        {
        "server_purpose" : "k8s-cp",
        "num_of_servers" : "1",
        "size" : "Standard_E2as_v5",
        "type" : "Regular",
        "evictpolicy" : "Deallocate"
        },
        {
        "server_purpose" : "k8s-node",
        "num_of_servers" : "3",
        "size" : "Standard_E4as_v5",
        "type" : "Regular",
        "evictpolicy" : "Deallocate"
        },
        {
        "server_purpose" : "k8s-support",
        "num_of_servers" : "1",
        "size" : "Standard_E2as_v5",
        "type" : "Regular",
        "evictpolicy" : "Deallocate"
        }
    ]
}