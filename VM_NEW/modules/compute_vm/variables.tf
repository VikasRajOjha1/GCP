variable "name_prefix" {
  description = "Prefix for VM and service account names."
  type        = string
}

variable "zone" {
  description = "Zone where the VM is created."
  type        = string
}

variable "machine_type" {
  description = "Compute Engine machine type."
  type        = string
}

variable "boot_disk_size_gb" {
  description = "Boot disk size in GiB."
  type        = number
}

variable "network_id" {
  description = "VPC network ID for the VM NIC."
  type        = string
}

variable "subnetwork_id" {
  description = "Subnet ID for the VM NIC."
  type        = string
}

variable "assign_public_ip" {
  description = "Whether to allocate an ephemeral external IPv4 address."
  type        = bool
}

variable "enable_iap_ssh" {
  description = "Whether the VM receives the tag targeted by the IAP SSH firewall rule."
  type        = bool
}

variable "labels" {
  description = "Labels to apply to the VM."
  type        = map(string)
}