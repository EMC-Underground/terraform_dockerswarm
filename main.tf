provider "vsphere" {
  user           = "${var.vsphere_user}"
  password       = "${var.vsphere_password}"
  vsphere_server = "${var.vsphere_server}"
  allow_unverified_ssl = true
}

# Stores the terraform state file in S3 bucket.
 terraform {
  backend "s3" {
    bucket = "brad.bucket"
    key    = "dockerswarm/terraform.tfstate"
    region = "us-east-1"
	}
}

module "Docker_Hostvm"{
  source       = "services/docker_hosts"
  servers      = "${var.node_count}"
  datastore    = "${var.datastore}"
  root_password = "${var.root_password}"
  cluster_name = "${var.cluster_name}"
}
