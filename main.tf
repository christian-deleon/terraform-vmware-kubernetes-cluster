########################################
# VMware General
########################################

data "vsphere_datacenter" "this" {
  name = var.datacenter
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
  source  = "gitlab.com/devops9483002/vmware-virtual-machine/vmware"
  version = "1.5.0"

  count = length(var.master_mapping)

  datacenter               = var.datacenter
  compute_cluster          = var.compute_cluster
  network                  = var.network
  host                     = var.master_mapping[count.index].host
  datastore                = var.master_mapping[count.index].datastore
  template                 = var.master_vm_template
  folder_path              = var.folder_path
  name                     = "${var.cluster_name}-master-${count.index + 1}"
  cores                    = var.master_cores
  memory                   = var.master_memory
  disk_size                = var.master_disk_size
  additional_disk_size     = var.master_additional_disk_size
  create_baseline_snapshot = var.create_baseline_snapshot
  tags                     = count.index == 0 ? ["${vsphere_tag.controlplane_master.id}", "${vsphere_tag.controlplane.id}"] : ["${vsphere_tag.controlplane_slave.id}", "${vsphere_tag.controlplane.id}"]

  depends_on = [vsphere_folder.this]
}

module "worker" {
  source  = "gitlab.com/devops9483002/vmware-virtual-machine/vmware"
  version = "1.5.0"

  count = length(var.worker_mapping)

  datacenter               = var.datacenter
  compute_cluster          = var.compute_cluster
  network                  = var.network
  host                     = var.worker_mapping[count.index].host
  datastore                = var.worker_mapping[count.index].datastore
  template                 = var.worker_vm_template
  folder_path              = var.folder_path
  name                     = "${var.cluster_name}-worker-${count.index + 1}"
  cores                    = var.worker_cores
  memory                   = var.worker_memory
  disk_size                = var.worker_disk_size
  additional_disk_size     = var.worker_additional_disk_size
  create_baseline_snapshot = var.create_baseline_snapshot
  tags                     = ["${vsphere_tag.worker.id}"]

  depends_on = [vsphere_folder.this]
}
