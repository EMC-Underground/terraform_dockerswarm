provider "vsphere" {
  user           = "${var.vsphere_user}"
  password       = "${var.vsphere_password}"
  vsphere_server = "${var.vsphere_server}"
  allow_unverified_ssl = true
}

module "Docker_Hostvm"{
  source       = "services/docker_hosts"
  servers      = "${var.node_count}"
  datastore    = "SIO_ds01"
  root_password = "${var.root_password}"
}
