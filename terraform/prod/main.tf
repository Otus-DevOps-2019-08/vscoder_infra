provider "google" {
  version = "2.15"
  project = var.project
  region  = var.region
}

module "app" {
  source          = "../modules/app"
  public_key_path = var.public_key_path
  zone            = var.zone
  app_disk_image  = var.app_disk_image
  environment     = var.environment
  use_static_ip   = var.use_static_ip
}

module "db" {
  source          = "../modules/db"
  public_key_path = var.public_key_path
  zone            = var.zone
  db_disk_image   = var.db_disk_image
  environment     = var.environment
}

module "vpc" {
  source        = "../modules/vpc"
  zone          = var.zone
  source_ranges = ["185.30.195.250/32", "176.62.181.4/32"]
  environment   = var.environment
}