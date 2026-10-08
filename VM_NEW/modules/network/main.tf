resource "google_compute_network" "this" {
  name                    = "${var.name_prefix}-network"
  auto_create_subnetworks = false
  description             = "Custom VPC for ${var.name_prefix}."
}

resource "google_compute_subnetwork" "this" {
  name                     = "${var.name_prefix}-subnet"
  ip_cidr_range            = var.subnet_cidr
  region                   = var.region
  network                  = google_compute_network.this.id
  description              = "Subnet for ${var.name_prefix}."
  private_ip_google_access = true
}

resource "google_compute_firewall" "iap_ssh" {
  count       = var.enable_iap_ssh ? 1 : 0
  name        = "${var.name_prefix}-allow-iap-ssh"
  network     = google_compute_network.this.name
  description = "Allow SSH from Google IAP TCP forwarding only."
  direction   = "INGRESS"
  priority    = 1000

  source_ranges = ["35.235.240.0/20"]
  target_tags   = ["${var.name_prefix}-iap-ssh"]

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }
}