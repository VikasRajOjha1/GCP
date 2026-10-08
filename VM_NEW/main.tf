module "network" {
  source = "./modules/network"

  name_prefix     = var.name_prefix
  region          = var.region
  subnet_cidr     = var.subnet_cidr
  enable_iap_ssh  = var.enable_iap_ssh
}

module "vm" {
  source = "./modules/compute_vm"

  name_prefix       = var.name_prefix
  zone              = var.zone
  machine_type      = var.machine_type
  boot_disk_size_gb = var.boot_disk_size_gb
  network_id        = module.network.network_id
  subnetwork_id     = module.network.subnetwork_id
  assign_public_ip  = var.assign_public_ip
  enable_iap_ssh    = var.enable_iap_ssh
  labels            = var.labels

  depends_on = [module.network]
}