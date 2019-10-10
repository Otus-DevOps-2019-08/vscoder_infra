variable zone {
  description = "Zone"
}
variable source_ranges {
  description = "Allowed IP addresses"
  default     = ["0.0.0.0/0"]
}
variable network_name {
  description = "Network name"
  default     = "default"
}
variable environment {
  description = "Environment name"
}
