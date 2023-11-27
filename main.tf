########################################
# VMware General
########################################

data "vsphere_datacenter" "this" {
  name = var.datacenter
}

resource "vsphere_folder" "this" {
  path          = var.cluster_name
  type          = "vm"
  datacenter_id = data.vsphere_datacenter.this.id
}

########################################
# VMware Tags
########################################

resource "vsphere_tag_category" "this" {
  name        = var.cluster_name
  cardinality = "MULTIPLE"
  description = "Managed by Terraform"

  associable_types = [
    "VirtualMachine",
  ]
}

resource "vsphere_tag" "controlplane" {
  name        = "controlplane"
  category_id = vsphere_tag_category.this.id
  description = "Managed by Terraform"
}

resource "vsphere_tag" "controlplane_master" {
  name        = "controlplane-master"
  category_id = vsphere_tag_category.this.id
  description = "Managed by Terraform"
}

resource "vsphere_tag" "controlplane_slave" {
  name        = "controlplane-slave"
  category_id = vsphere_tag_category.this.id
  description = "Managed by Terraform"
}

resource "vsphere_tag" "worker" {
  name        = "worker"
  category_id = vsphere_tag_category.this.id
  description = "Managed by Terraform"
}

########################################
# Virtual Machines
########################################

module "master" {
  count = length(var.master_datastores)

  source  = "gitlab.robochris.net/devops/vmware-virtual-machine/vmware"
  version = "0.8.0"

  template             = var.vm_template
  name                 = "${var.cluster_name}-k8s-master-${count.index + 1}"
  cores                = var.master_cores
  memory               = var.master_memory
  root_disk_size       = var.master_disk_size
  additional_disk_size = var.master_additional_disk_size
  tags                 = count.index == 0 ? ["${vsphere_tag.controlplane_master.id}", "${vsphere_tag.controlplane.id}"] : ["${vsphere_tag.controlplane_slave.id}", "${vsphere_tag.controlplane.id}"]
  vsphere_datastore    = var.master_datastores[count.index]
  vsphere_folder       = vsphere_folder.this.path
}

module "worker" {
  count = length(var.worker_datastores)

  source  = "gitlab.robochris.net/devops/vmware-virtual-machine/vmware"
  version = "0.8.0"

  template             = var.vm_template
  name                 = "${var.cluster_name}-k8s-worker-${count.index + 1}"
  cores                = var.worker_cores
  memory               = var.worker_memory
  root_disk_size       = var.worker_disk_size
  additional_disk_size = var.worker_additional_disk_size
  tags                 = ["${vsphere_tag.worker.id}"]
  vsphere_datastore    = var.worker_datastores[count.index]
  vsphere_folder       = vsphere_folder.this.path
}
