variable "project_id" {
  description = "Google Cloud project ID where the VM and network will be created."
  type        = string
}

variable "region" {
  description = "Google Cloud region for the subnet."
  type        = string
  default     = "us-central1"

  validation {
    condition     = contains(["us-central1", "us-east1", "us-west1"], var.region)
    error_message = "For the free-tier-oriented configuration, choose us-central1, us-east1, or us-west1."
  }
}

variable "zone" {
  description = "Google Cloud zone for the VM; it must be in the selected region."
  type        = string
  default     = "us-central1-a"

  validation {
    condition     = startswith(var.zone, "${var.region}-")
    error_message = "zone must be in the selected region (for example, us-central1-a for us-central1)."
  }
}

variable "name_prefix" {
  description = "Prefix used for VM, network, and service account names."
  type        = string
  default     = "tutorial-vm"

  validation {
    condition     = can(regex("^[a-z][a-z0-9-]{0,20}[a-z0-9]$", var.name_prefix))
    error_message = "name_prefix must be 2-22 lowercase letters, digits, or hyphens, and start with a letter."
  }
}

variable "machine_type" {
  description = "Compute Engine machine type."
  type        = string
  default     = "e2-micro"
}

variable "boot_disk_size_gb" {
  description = "Boot disk size in GiB; keep at or below 30 GiB to stay within the free-tier disk allowance."
  type        = number
  default     = 10

  validation {
    condition     = var.boot_disk_size_gb >= 10 && var.boot_disk_size_gb <= 30
    error_message = "boot_disk_size_gb must be between 10 and 30 GiB."
  }
}

variable "subnet_cidr" {
  description = "IPv4 range for the VM subnet."
  type        = string
  default     = "10.10.0.0/24"
}

variable "enable_iap_ssh" {
  description = "Allow SSH only through Identity-Aware Proxy (IAP); no public SSH ingress is opened."
  type        = bool
  default     = true
}

variable "assign_public_ip" {
  description = "Assign an external IPv4 address. Disabled by default to avoid public-IP charges."
  type        = bool
  default     = false
}

variable "labels" {
  description = "Labels added to the VM."
  type        = map(string)
  default     = { managed_by = "terraform" }
}