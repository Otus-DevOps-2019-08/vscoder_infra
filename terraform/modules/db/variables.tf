variable public_key_path {
  description = "Path to the public key used to connect to instance"
}

variable zone {
  description = "Zone"
}

variable db_disk_image {
  description = "Disk image for reddit db"
  default     = "reddit-db-base"
}

variable vpc_network_name {
  description = "Network name"
  default     = "default"
}

variable environment {
  description = "Environment name"
}
