variable "servers"{}
variable "datastore"{}
variable "root_password"{}

data "vsphere_datacenter" "dc" {
  name = "PacLabs"
}

data "vsphere_datastore" "datastore" {
  name = "${var.datastore}"
  datacenter_id = "${data.vsphere_datacenter.dc.id}"
}

data "vsphere_compute_cluster" "cluster" {
  name          = "SIODev"
  datacenter_id = "${data.vsphere_datacenter.dc.id}"
}

data "vsphere_resource_pool" "pool" {
  name          = "SIODev/Resources"
  datacenter_id = "${data.vsphere_datacenter.dc.id}"
}

data "vsphere_network" "vlan344" {
  name          = "siodev_pg_344"
  datacenter_id = "${data.vsphere_datacenter.dc.id}"
}

data "vsphere_network" "sio_pg1" {
  name          = "siodev_sio_pg1"
  datacenter_id = "${data.vsphere_datacenter.dc.id}"
}

data "vsphere_network" "sio_pg2" {
  name          = "siodev_sio_pg2"
  datacenter_id = "${data.vsphere_datacenter.dc.id}"
}

data "vsphere_virtual_machine" "template" {
  name          = "SIODev_CentOS7_Template"
  datacenter_id = "${data.vsphere_datacenter.dc.id}"
}

resource "vsphere_virtual_machine" "Docker_Hostvm" {
  count            = "${var.servers}"
  name             = "terraform-DockerHost${count.index}"
  resource_pool_id = "${data.vsphere_compute_cluster.cluster.resource_pool_id}"
  datastore_id     = "${data.vsphere_datastore.datastore.id}"
  num_cpus         = 2
  memory           = 4096
  guest_id         = "${data.vsphere_virtual_machine.template.guest_id}"
  scsi_type        = "${data.vsphere_virtual_machine.template.scsi_type}"

  network_interface {
    network_id     = "${data.vsphere_network.vlan344.id}"
    adapter_type   = "${data.vsphere_virtual_machine.template.network_interface_types[0]}"
  }

  network_interface {
    network_id     = "${data.vsphere_network.sio_pg1.id}"
    adapter_type   = "${data.vsphere_virtual_machine.template.network_interface_types[0]}"
  }

  network_interface {
    network_id     = "${data.vsphere_network.sio_pg2.id}"
    adapter_type   = "${data.vsphere_virtual_machine.template.network_interface_types[0]}"
  }

  disk {
    label            = "disk0"
    size             = "${data.vsphere_virtual_machine.template.disks.0.size}"
    eagerly_scrub    = "${data.vsphere_virtual_machine.template.disks.0.eagerly_scrub}"
    thin_provisioned = "${data.vsphere_virtual_machine.template.disks.0.thin_provisioned}"
  }

  clone {
    template_uuid = "${data.vsphere_virtual_machine.template.id}"

    customize {
      linux_options {
        host_name = "terraform-DockerHost${count.index}"
        domain    = "paclabs.se.lab.emc.com"
      }

     network_interface {
        ipv4_address = "10.237.198.19${count.index}"
        ipv4_netmask = 24
      }

      network_interface {
      }

      network_interface {
      }
      ipv4_gateway = "10.237.198.1"
      dns_server_list = ["10.237.198.254", "10.201.16.29"]
      }

}

  provisioner "file" {
    source      = "./authorized_keys"
    destination = "/root/.ssh/authorized_keys"

  connection {
    type     = "ssh"
    user     = "root"
    password = "${var.root_password}"
}
}
}
