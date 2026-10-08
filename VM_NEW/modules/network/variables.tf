variable "name_prefix" {
  description = "Prefix for network resource names and the SSH network tag."
  type        = string
}

variable "region" {
  description = "Region for the subnet."
  type        = string
}

variable "subnet_cidr" {
  description = "IPv4 range for the subnet."
  type        = string
}

variable "enable_iap_ssh" {
  description = "Whether to allow SSH from the IAP TCP forwarding range."
  type        = bool
}