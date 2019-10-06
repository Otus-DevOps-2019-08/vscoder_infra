variable public_key_path {
  description = "Path to the public key used to connect to instance"
}

variable zone {
  description = "Zone"
}

variable app_disk_image {
  description = "Disk image for reddit app"
  default     = "reddit-app-base"
}

variable network_name {
  description = "Network name"
  default     = "default"
}

variable environment {
  description = "Environment name"
}

variable use_static_ip {
  description = "Need to create static ip for instance?"
  default     = false
}
