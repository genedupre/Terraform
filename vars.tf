variable "vsphere_user" {
  description = "What is your vSphere user?"
}

variable "vsphere_password" {
  description = "What is your vSphere password?"
}

variable "vsphere_server" {
  description = "What is your vSphere server?"
  default = "vcenter.cloud2.local"
}

variable "datastore" {
  description = "Which datastore?"
}

variable "vm_hostname" {
  description = "What should be the hostname?"
}

variable "vm_folder" {
  description = "Which folder?"
}

variable "vm_count" {
  description = "How many VMs?"
}

variable "vm_cpu_cores" {
  description = "How many cores?"
}

variable "vm_ram" {
  description = "How much RAM (MB)?"
}