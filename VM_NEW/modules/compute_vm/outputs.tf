output "instance_name" {
  description = "Name of the created Compute Engine VM."
  value       = google_compute_instance.this.name
}

output "instance_zone" {
  description = "Zone containing the VM."
  value       = google_compute_instance.this.zone
}

output "instance_external_ip" {
  description = "Ephemeral external IPv4 address, or null when public IP assignment is disabled."
  value       = try(google_compute_instance.this.network_interface[0].access_config[0].nat_ip, null)
}

output "instance_internal_ip" {
  description = "Internal IPv4 address assigned to the VM."
  value       = google_compute_instance.this.network_interface[0].network_ip
}

output "service_account_email" {
  description = "Dedicated service account attached to the VM."
  value       = google_service_account.this.email
}