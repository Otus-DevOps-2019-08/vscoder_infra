resource "google_compute_instance" "db" {
  name         = "reddit-db-${var.environment}"
  machine_type = "g1-small"
  zone         = var.zone
  tags         = ["reddit-db"]
  boot_disk {
    initialize_params {
      image = var.db_disk_image
    }
  }
  network_interface {
    network = "${var.vpc_network_name}"
    access_config {}
  }
  metadata = {
    ssh-keys = "appuser:${file(var.public_key_path)}"
  }
}
resource "google_compute_firewall" "firewall_mongo" {
  name    = "allow-mongo-default-${var.environment}"
  network = "${var.vpc_network_name}"
  allow {
    protocol = "tcp"
    ports    = ["27017"]
  }
  target_tags = ["reddit-db"]
  source_tags = ["reddit-app"]
}
