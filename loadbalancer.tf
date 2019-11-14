resource "vsphere_virtual_machine" "loadbalancer" {
  connection {
    type = "ssh"
    user = "student"
    password = var.ubuntu_pass
    host = self.default_ip_address
  }

  folder = vsphere_folder.folder.path
  name = var.vm_hostname_lb
  datastore_id = data.vsphere_datastore.datastore.id
  resource_pool_id = data.vsphere_resource_pool.pool.id

  num_cpus = var.vm_cpu_cores
  memory = var.vm_ram
  count = 1
  guest_id = data.vsphere_virtual_machine.template.guest_id

  scsi_type = data.vsphere_virtual_machine.template.scsi_type

  network_interface {
    network_id = data.vsphere_network.network.id
    adapter_type = data.vsphere_virtual_machine.template.network_interface_types[0]
  }

  provisioner "file" {
    source = "nginx.conf"
    destination = "/tmp/nginx.conf"
  }

  provisioner "file" {
    content = templatefile("servers.tpl", {
      ip_addrs = vsphere_virtual_machine.webserver.*.default_ip_address
    })
    destination = "/tmp/servers.conf"
  }

  provisioner "remote-exec" {
    inline = [
      "echo '${var.ubuntu_pass}' | sudo -S apt update",
      "echo '${var.ubuntu_pass}' | sudo -S apt install nginx -y",
      "echo '${var.ubuntu_pass}' | sudo -S mv /tmp/nginx.conf /etc/nginx/nginx.conf",
      "echo '${var.ubuntu_pass}' | sudo -S mv /tmp/servers.conf /etc/nginx/servers.conf",
      "echo '${var.ubuntu_pass}' | sudo -S systemctl restart nginx",
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
        host_name = var.vm_hostname_lb
        domain = "cloud2.local"
      }

      network_interface {}
    }
  }
}