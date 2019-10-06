terraform {
  required_version = ">= 0.12.8, <= 0.12.9"
}

provider "google" {
  version = "2.15"
  project = var.project
  region  = var.region
}

resource "google_compute_project_metadata_item" "ssh-keys" {
  key   = "ssh-keys"
  value = join("\n", var.ssh_keys)
}
