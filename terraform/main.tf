terraform {
  required_version = "0.12.9"
}

provider "google" {
  version = "2.15"
  project = "infra-253214"
  region = "europe-west1"
}
