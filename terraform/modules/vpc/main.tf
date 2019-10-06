resource "google_compute_firewall" "firewall_ssh" {
  name    = "${var.network_name}-allow-ssh-${var.environment}"
  network = "${var.network_name}-${var.environment}"
  allow {
    protocol = "tcp"
    ports    = ["22"]
  }
  source_ranges = var.source_ranges
}
resource "google_compute_network" "vpc_network" {
  name                    = "${var.network_name}-${var.environment}"
  auto_create_subnetworks = true
}
