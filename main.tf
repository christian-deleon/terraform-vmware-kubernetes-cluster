########################################
# VMware General
########################################

data "vsphere_datacenter" "this" {
  name = var.datacenter
}

data "vsphere_folder" "this" {
  count = var.create_folder ? 0 : 1

  path = var.folder_path
}

resource "vsphere_folder" "this" {
  count = var.create_folder ? 1 : 0

  path          = var.folder_path
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
  version = "1.0.0"

  datacenter           = var.datacenter
  compute_cluster      = var.compute_cluster
  network              = var.network
  template             = var.master_vm_template
  datastore            = var.master_datastores[count.index]
  folder               = var.folder_path
  name                 = "${var.cluster_name}-k8s-master-${count.index + 1}"
  cores                = var.master_cores
  memory               = var.master_memory
  disk_size            = var.master_disk_size
  additional_disk_size = var.master_additional_disk_size
  tags                 = count.index == 0 ? ["${vsphere_tag.controlplane_master.id}", "${vsphere_tag.controlplane.id}"] : ["${vsphere_tag.controlplane_slave.id}", "${vsphere_tag.controlplane.id}"]
}

module "worker" {
  count = length(var.worker_datastores)

  source  = "gitlab.robochris.net/devops/vmware-virtual-machine/vmware"
  version = "1.0.0"

  datacenter           = var.datacenter
  compute_cluster      = var.compute_cluster
  network              = var.network
  template             = var.worker_vm_template
  datastore            = var.worker_datastores[count.index]
  folder               = var.folder_path
  name                 = "${var.cluster_name}-k8s-worker-${count.index + 1}"
  cores                = var.worker_cores
  memory               = var.worker_memory
  disk_size            = var.worker_disk_size
  additional_disk_size = var.worker_additional_disk_size
  tags                 = ["${vsphere_tag.worker.id}"]
}
