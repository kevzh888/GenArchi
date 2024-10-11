terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "5.23.0"
    }
  }
}

provider "google" {
  # Configuration options
  project     = "openstack-419419"
  region      = "europe-west9"
  zone        = "europe-west9-a"
  credentials = "./openstack-keys.json"
}