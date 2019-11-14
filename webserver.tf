provider "vsphere" {
  user = var.vsphere_user
  password = var.vsphere_password
  vsphere_server = var.vsphere_server

  allow_unverified_ssl = true
}

data "vsphere_datacenter" "dc" {
  name = "Labo"
}

data "vsphere_datastore" "datastore" {
  name = var.datastore
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_resource_pool" "pool" {
  name = "DRS-Cluster/Resources"
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_network" "network" {
  name = "VM Network"
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_virtual_machine" "template" {
  name = "ubuntu-1804-tpl"
  datacenter_id = data.vsphere_datacenter.dc.id
}

resource "vsphere_folder" "folder" {
  path = var.vm_folder
  type = "vm"
  datacenter_id = data.vsphere_datacenter.dc.id
}

resource "vsphere_virtual_machine" "webserver" {
  connection {
    type = "ssh"
    user = "student"
    password = var.ubuntu_pass
    host = self.default_ip_address
  }
  folder = vsphere_folder.folder.path
  name = format("%s-%02d", var.vm_hostname, count.index)
  datastore_id = data.vsphere_datastore.datastore.id
  resource_pool_id = data.vsphere_resource_pool.pool.id

  //  num_cpus = var.vm_cpu_cores
  //  memory = var.vm_ram
  count = var.vm_count

  guest_id = data.vsphere_virtual_machine.template.guest_id

  scsi_type = data.vsphere_virtual_machine.template.scsi_type

  network_interface {
    network_id = data.vsphere_network.network.id
    adapter_type = data.vsphere_virtual_machine.template.network_interface_types[0]
  }

  provisioner "remote-exec" {
    inline = [
      "echo '${var.ubuntu_pass}' | sudo -S apt update",
      "echo '${var.ubuntu_pass}' | sudo -S apt install nginx -y",
      "echo '${var.ubuntu_pass}' | sudo -S sed -i 's/to nginx/to ${format("%s-%02d", var.vm_hostname, count.index)}/g' /var/www/html/index.nginx-debian.html"
    ]
  }

  disk {
    label = "disk_os"
    size = data.vsphere_virtual_machine.template.disks[0].size
    eagerly_scrub = data.vsphere_virtual_machine.template.disks[0].eagerly_scrub
    thin_provisioned = data.vsphere_virtual_machine.template.disks[0].thin_provisioned
  }

  clone {
    template_uuid = data.vsphere_virtual_machine.template.id

    customize {
      linux_options {
        host_name = format("%s-%02d", var.vm_hostname, count.index)
        domain = "cloud2.local"
      }

      network_interface {}
    }
  }
}