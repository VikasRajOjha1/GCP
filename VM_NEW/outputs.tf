output "instance_name" {
  description = "Name of the created Compute Engine VM."
  value       = module.vm.instance_name
}

output "instance_zone" {
  description = "Zone containing the VM."
  value       = module.vm.instance_zone
}

output "instance_external_ip" {
  description = "Ephemeral external IPv4 address, or null when public IP assignment is disabled."
  value       = module.vm.instance_external_ip
}

output "instance_internal_ip" {
  description = "Internal IPv4 address assigned to the VM."
  value       = module.vm.instance_internal_ip
}

output "vm_service_account" {
  description = "Dedicated service account attached to the VM."
  value       = module.vm.service_account_email
}