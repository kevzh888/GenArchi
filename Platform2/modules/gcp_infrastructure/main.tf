data "google_compute_network" "existing_network" {
  name = "openstack-private-network"
}

resource "google_compute_disk" "ubuntu2204disk" {
  name  = "ubuntu2204disk"
  type  = "pd-standard"
  image = "ubuntu-2204-lts"
  zone  = "europe-west9-a"
}
# gcloud compute disks delete ubuntu2204disk --zone europe-west9-a

resource "google_compute_image" "ubuntu-2204-nested" {
  name        = "ubuntu-2204-nested"
  source_disk = google_compute_disk.ubuntu2204disk.self_link
  licenses    = ["https://www.googleapis.com/compute/v1/projects/vm-options/global/licenses/enable-vmx"]
}
# gcloud compute images delete ubuntu-2204-nested

resource "google_compute_instance" "gcp-vm-for-openstack-tf" {
  name         = "gcp-vm-for-openstack-tf"
  zone         = "europe-west9-a"
  machine_type = "e2-standard-8"

  boot_disk {
    initialize_params {
      image = google_compute_image.ubuntu-2204-nested.self_link
      size  = "600"
      type  = "pd-standard"
    }
  }

  //network_interface {
   // access_config {
    //  nat_ip       = "34.1.6.229"
    //  network_tier = "STANDARD"
    //}

    //queue_count = 0
    //stack_type  = "IPV4_ONLY"
    //subnetwork  = "projects/openstack-419419/regions/europe-west9/subnetworks/default"
  //}

  network_interface {
    access_config {
      nat_ip       = "34.155.58.154"
      network_tier = "PREMIUM"
    }

    queue_count = 0
    stack_type  = "IPV4_ONLY"
    subnetwork  = "projects/openstack-419419/regions/europe-west9/subnetworks/default"
  }

  network_interface {
    access_config {
      nat_ip       = "34.1.13.50"
      network_tier = "STANDARD"
    }

    queue_count = 0
    stack_type  = "IPV4_ONLY"
    subnetwork  = "projects/openstack-419419/regions/europe-west9/subnetworks/openstack-subnet"
  }

  can_ip_forward = true
  advanced_machine_features {
    enable_nested_virtualization = true
  }

  metadata_startup_script = "echo hi > /test.txt"
  #allow_stopping_for_update = true

  tags = ["http-server", "https-server", "novnc", "openstack-apis"]
}