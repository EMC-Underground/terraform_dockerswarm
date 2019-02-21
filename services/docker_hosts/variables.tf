variable "root_password" {}
variable "node_count" {}
variable "datacenter_name" {}
variable "cluster_name" {}
variable "datastore" {}
variable "template_name" {}
variable "vm_name_prefix" {}
variable "network_0" {}
variable "network_1" {}
variable "network_2" {}
variable "mgmt_ip_prefix" {}
variable "mgmt_netmask" {}
variable "gateway" {}

variable "dns_servers" {
  type = "list"
}

variable "domain" {}
