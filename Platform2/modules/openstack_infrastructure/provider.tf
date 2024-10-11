terraform {
  required_providers {
    openstack = {
      source  = "terraform-provider-openstack/openstack"
      version = "1.46.0"
    }
  }
}

#provider "google" {
# Configuration options
#  project = "openstack-419419"
#  region = "europe-west9"
#  zone = "europe-west9-a"
#  credentials = "./openstack-keys.json"
#}