data "vsphere_datacenter" "dc" {
  name = "${var.datacenter_name}"
}

data "vsphere_datastore" "datastore" {
  name          = "${var.datastore}"
  datacenter_id = "${data.vsphere_datacenter.dc.id}"
}

data "vsphere_compute_cluster" "cluster" {
  name          = "${var.cluster_name}"
  datacenter_id = "${data.vsphere_datacenter.dc.id}"
}

data "vsphere_resource_pool" "pool" {
  name          = "${var.cluster_name}/Resources"
  datacenter_id = "${data.vsphere_datacenter.dc.id}"
}

data "vsphere_network" "mgmt_pg1" {
  name          = "${var.network_0}"
  datacenter_id = "${data.vsphere_datacenter.dc.id}"
}

data "vsphere_network" "sio_pg1" {
  name          = "${var.network_1}"
  datacenter_id = "${data.vsphere_datacenter.dc.id}"
}

data "vsphere_network" "sio_pg2" {
  name          = "${var.network_2}"
  datacenter_id = "${data.vsphere_datacenter.dc.id}"
}

data "vsphere_virtual_machine" "template" {
  name          = "${var.template_name}"
  datacenter_id = "${data.vsphere_datacenter.dc.id}"
}

resource "vsphere_virtual_machine" "Docker_Hostvm" {
  count            = "${var.node_count}"
  name             = "${var.vm_name_prefix}${count.index}"
  resource_pool_id = "${data.vsphere_compute_cluster.cluster.resource_pool_id}"
  datastore_id     = "${data.vsphere_datastore.datastore.id}"
  num_cpus         = 2
  memory           = 4096
  guest_id         = "${data.vsphere_virtual_machine.template.guest_id}"
  scsi_type        = "${data.vsphere_virtual_machine.template.scsi_type}"

  network_interface {
    network_id   = "${data.vsphere_network.mgmt_pg1.id}"
    adapter_type = "${data.vsphere_virtual_machine.template.network_interface_types[0]}"
  }

  network_interface {
    network_id   = "${data.vsphere_network.sio_pg1.id}"
    adapter_type = "${data.vsphere_virtual_machine.template.network_interface_types[0]}"
  }

  network_interface {
    network_id   = "${data.vsphere_network.sio_pg2.id}"
    adapter_type = "${data.vsphere_virtual_machine.template.network_interface_types[0]}"
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
        host_name = "${var.vm_name_prefix}${count.index}"
        domain    = "${var.domain}"
      }

      network_interface {
        ipv4_address = "${var.mgmt_ip_prefix}${count.index}"
        ipv4_netmask = "${var.mgmt_netmask}"
      }

      network_interface {}

      network_interface {}

      ipv4_gateway    = "${var.gateway}"
      dns_server_list = "${var.dns_servers}"
    }
  }

  provisioner "file" {
    source      = "./authorized_keys"
    destination = "/root/.ssh/authorized_keys"

    connection {
      type     = "ssh"
      host     = "${self.default_ip_address}"
      user     = "root"
      password = "${var.root_password}"
    }
  }
}
