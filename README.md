# VMware Virtual Machine

## Using this module

Set GitLab Token

```bash
export GITLAB_TOKEN="<gitlab_token>"
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
  }
}

provider "gitlab" {
  base_url = "https://gitlab.com/api/v4/"
}

provider "vsphere" {
  user                 = var.vsphere_username
  password             = var.vsphere_password
  vsphere_server       = var.vsphere_server_ip
  allow_unverified_ssl = true
}

module "k8s_cluster" {
  source = "gitlab.com/terraform2584837/vmware-kubernetes-cluster/vmware"
  version = "~> 0.11.0"

  datacenter         = var.datacenter
  cluster_name       = var.cluster_name
  master_vm_template = var.master_vm_template
  worker_vm_template = var.worker_vm_template
}
```
