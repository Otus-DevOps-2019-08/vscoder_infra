provider "google" {
  version = "2.15"
  project = var.project
  region  = var.region
}

module "vpc" {
  source        = "../modules/vpc"
  zone          = var.zone
  source_ranges = ["0.0.0.0/0"]
  environment   = var.environment
}

module "db" {
  source          = "../modules/db"
  public_key_path = var.public_key_path
  zone            = var.zone
  db_disk_image   = var.db_disk_image
  environment     = var.environment
}

module "app" {
  source          = "../modules/app"
  public_key_path = var.public_key_path
  private_key_path = var.private_key_path
  zone            = var.zone
  app_disk_image  = var.app_disk_image
  environment     = var.environment
  use_static_ip   = var.use_static_ip
  database_url    = "${module.db.db_internal_ip}:27017"
}
