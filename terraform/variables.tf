variable project {
  description = "Project ID"
}
variable region {
  description = "Region"
  default     = "europe-west1"
}
variable zone {
  description = "Zone"
  default     = "europe-west1-d"
}
variable public_key_path {
  description = "Path to the public key used for ssh access"
}
variable private_key_path {
  description = "Path to the private key used for provisioners"
}
variable disk_image {
  description = "Disk image"
}
variable ssh_keys {
  type = list(string)
}
variable instances {
  type = set(string)
}
