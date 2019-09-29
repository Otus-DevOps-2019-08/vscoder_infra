terraform {
  required_version = "0.12.9"
}

provider "google" {
  version = "2.15"
  project = "infra-253214"
  region = "europe-west1"
}

resource "google_compute_instance" "app" {
  name = "reddit-app"
  machine_type = "g1-small"
  zone = "europe-west1-d"
  boot_disk {
    initialize_params {
      image = "reddit-base"
    }
  }
  
  network_interface {
    network = "default"
    access_config {}
  }

  metadata = {
    ssh-keys = "appuser:${file("~/.ssh/appuser.pub")}"
  }
}
