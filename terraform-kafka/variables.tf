variable "vpc_name" {
  description = "GCE VPC Network Name"
  default     = "projects/data-qe-da7e1252/regions/us-west1/subnetworks/default"
}

variable "env" {
  description = "GCP Project Environment"
  default     = "test"
}

