resource "google_compute_disk" "kafka-v02-disk1" {
  name = "kafka-v02-disk1"
  type = "pd-standard"
  size = 25
  labels = {
    environment = "poc"
    brand       = "poc-slalom"
    name        = "kafka-v02-disk1"
  }
}

resource "google_compute_instance" "kafka-v02" {
  name         = "kafka-v02"
  machine_type = "n1-standard-2"

  tags = ["qe", "kafka", "no-ip"]

  boot_disk {
    initialize_params {
      image = "ubuntu-1604-lts-dio"
      type  = "pd-ssd"
    }
  }

  labels = {
    environment = "poc"
    brand       = "poc-slalom"
    name        = "kafka-v02"
  }

  attached_disk {
    source = google_compute_disk.kafka-v02-disk1.name
  }

  network_interface {
    subnetwork = var.vpc_name
  }

  metadata = {
    name = "kafka-v02"
  }

  service_account {
    email  = "dio-sa@data-qe-da7e1252.iam.gserviceaccount.com"
    scopes = ["userinfo-email", "compute-rw", "storage-rw"]
  }
}

resource "google_compute_disk" "kafka-v03-disk1" {
  name = "kafka-v03-disk1"
  type = "pd-standard"
  size = 25
  labels = {
    environment = "poc"
    brand       = "poc-slalom"
    name        = "kafka-v03-disk1"
  }
}

resource "google_compute_instance" "kafka-v03" {
  name         = "kafka-v03"
  machine_type = "n1-standard-2"

  tags = ["qe", "kafka", "no-ip"]

  boot_disk {
    initialize_params {
      image = "ubuntu-1604-lts-dio"
      type  = "pd-ssd"
    }
  }

  labels = {
    environment = "poc"
    brand       = "poc-slalom"
    name        = "kafka-v03"
  }

  attached_disk {
    source = google_compute_disk.kafka-v03-disk1.name
  }

  network_interface {
    subnetwork = var.vpc_name
  }

  metadata = {
    name = "kafka-v03"
  }

  service_account {
    email  = "dio-sa@data-qe-da7e1252.iam.gserviceaccount.com"
    scopes = ["userinfo-email", "compute-rw", "storage-rw"]
  }
}