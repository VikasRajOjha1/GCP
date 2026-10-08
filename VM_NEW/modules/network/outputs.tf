output "network_id" {
  description = "ID of the VPC created by this module."
  value       = google_compute_network.this.id
}

output "subnetwork_id" {
  description = "ID of the subnet created by this module."
  value       = google_compute_subnetwork.this.id
}