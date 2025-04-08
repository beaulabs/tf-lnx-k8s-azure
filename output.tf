
# Network related output

output "server_public_ips" {
    value = tomap({
        for name, server in azurerm_linux_virtual_machine.us_sa_k8s_lnxservers : name => server.public_ip_address
    })
}

# If you just want the list of public IP addresses you can uncomment the output below
# output "public_ip_address" {
#     value = azurerm_linux_virtual_machine.us_sa_k8s_lnxservers.*.public_ip_address
# }


# Storage related output

# output "primary_storage_account_key" {
#     value = azurerm_storage_account.us_sa_k8s_storageaccount.primary_access_key
#     sensitive = true
# }

# output "secondary_storage_account_key" {
#     value = azurerm_storage_account.us_sa_k8s_storageaccount.secondary_access_key
#     sensitive = true
# }

# output "primary_storage_connection_string" {
#     value = azurerm_storage_account.us_sa_k8s_storageaccount.primary_connection_string
#     sensitive = true
# }

# output "primary_storage_name" {
#     value = azurerm_storage_account.us_sa_k8s_storageaccount.name
# }

# output "primary_filestorage_full_url" {
#     value = azurerm_storage_share.us_sa_k8s_fileshare.url
# }

# output "primary_filestorage_endpoint"{
#     value = azurerm_storage_account.us_sa_k8s_storageaccount.primary_file_endpoint
# }

# output "primary_filestorage_filehost" {
#     value = azurerm_storage_account.us_sa_k8s_storageaccount.primary_file_host
# }