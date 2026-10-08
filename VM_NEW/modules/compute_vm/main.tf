resource "google_service_account" "this" {
  account_id   = "${var.name_prefix}-vm"
  display_name = "Service account for ${var.name_prefix} VM"
  description  = "Dedicated VM identity; grant only the application roles it needs."
}

resource "google_compute_instance" "this" {
  name                      = "${var.name_prefix}-instance"
  machine_type              = var.machine_type
  zone                      = var.zone
  tags                      = var.enable_iap_ssh ? ["${var.name_prefix}-iap-ssh"] : []
  labels                    = var.labels
  can_ip_forward            = false
  deletion_protection       = false
  allow_stopping_for_update = true

  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-2404-lts-amd64"
      size  = var.boot_disk_size_gb
      type  = "pd-standard"
    }
  }

  network_interface {
    network    = var.network_id
    subnetwork = var.subnetwork_id

    dynamic "access_config" {
      for_each = var.assign_public_ip ? [true] : []

      content {}
    }
  }

  service_account {
    email  = google_service_account.this.email
    scopes = ["https://www.googleapis.com/auth/cloud-platform"]
  }

  scheduling {
    automatic_restart   = true
    on_host_maintenance = "MIGRATE"
  }

  metadata = {
    enable-oslogin = "TRUE"
  }
}