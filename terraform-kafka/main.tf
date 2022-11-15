provider "google" {
  project = "data-qe-da7e1252"
  region  = "us-west1"
  zone    = "us-west1-b"
}

variable "id_subnet" {
  type    = string
  default = "default"
}

variable "gce_ssh_user" {
  default = "ansible"
}

variable "gce_ssh_pub_key_file" {
  default = ""
}

