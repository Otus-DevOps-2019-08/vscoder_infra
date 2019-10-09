variable public_key_path {
  description = "Path to the public key used to connect to instance"
}

variable private_key_path {
  description = "Path to ssh private key file for provisioners authentication"
  default = "~/.ssh/id_rsa"
}

variable zone {
  description = "Zone"
}

variable app_disk_image {
  description = "Disk image for reddit app"
  default     = "reddit-app-base"
}

variable vpc_network_name {
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

variable database_url {
  description = "MongoDB url. Ex: 127.0.0.1:27017"
}
