terraform {
  required_version = ">= 0.12.8, <= 0.12.9"
}

provider "google" {
  version = "2.15"
  project = var.project
  region  = var.region
}
