# VMware Virtual Machine

## Using this module

Set GitLab Token

```bash
export GITLAB_TOKEN="<gitlab_token>"
```

Example `variables.tf`

```hcl
variable "vsphere_username" {
  type = string
}

variable "vsphere_password" {
  type      = string
  sensitive = true
}
```

Example `main.tf`

```hcl
terraform {
  required_version = "~> 1.6"

  required_providers {
    vsphere = {
      source  = "hashicorp/vsphere"
      version = "~> 2.5.1"
    }
    gitlab = {
      source = "gitlabhq/gitlab"
    }
  }
}

provider "vsphere" {
  vsphere_server       = "vcenter.example.com"
  allow_unverified_ssl = true
  user                 = var.vsphere_username
  password             = var.vsphere_password
}

module "k8s_cluster" {
  source = "gitlab.robochris.net/devops/vmware-kubernetes-cluster/vmware"
  version = "~> 1.2.1"

  datacenter      = "Datacenter"
  compute_cluster = "cluster-01"
  network         = "VM Network"
  create_folder   = true
  folder_path     = "k8s-cluster"
  cluster_name    = "k8s-cluster"

  # Master
  master_vm_template = "ubuntu-20"
  master_cores       = local.cores
  master_memory      = local.memory
  master_disk_size   = local.disk_size

  master_mapping = [
    {
      host      = null
      datastore = "host1_datastore1"
    },
    {
      host      = null
      datastore = "host2_datastore1"
    }
  ]

  # Worker
  worker_vm_template = "ubuntu-20"
  worker_cores       = local.cores
  worker_memory      = local.memory
  worker_disk_size   = local.disk_size

  worker_mapping = [
    {
      host      = null
      datastore = "host1_datastore1"
    },
    {
      host      = null
      datastore = "host2_datastore1"
    }
  ]
}
```
