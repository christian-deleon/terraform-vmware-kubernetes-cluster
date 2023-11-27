variable "datacenter" {
  type        = string
  description = "The name of the datacenter to use for the virtual machines."
}

variable "compute_cluster" {
  type        = string
  description = "The name of the compute cluster to use for the virtual machines."
}

variable "network" {
  type        = string
  description = "The name of the network to use for the virtual machines."
}

variable "create_folder" {
  type        = bool
  default     = true
  description = "Whether or not to create a folder for the virtual machines."
}

variable "folder_path" {
  type        = string
  default     = null
  description = "The path to the folder to use for the virtual machines."
}

variable "cluster_name" {
  type        = string
  description = "The name of the cluster."
}

########################################
# Master
########################################

variable "master_vm_template" {
  type        = string
  description = "The name of the template to use for the master nodes."
}

variable "master_datastores" {
  type        = list(string)
  default     = []
  description = "The datastores to use for the master nodes."

  validation {
    condition     = length(var.master_datastores) >= 1
    error_message = "At least one datastore must be specified."
  }
}

variable "master_cores" {
  type        = number
  default     = 4
  description = "The number of cores to allocate to each master node."

  validation {
    condition     = var.master_cores >= 4 && var.master_cores <= 8
    error_message = "The number of cores must be between 4 and 8."
  }
}

variable "master_memory" {
  type        = number
  default     = 4096
  description = "The amount of memory to allocate to each master node."

  validation {
    condition     = var.master_memory >= 4096 && var.master_memory <= 16384
    error_message = "The amount of memory must be between 4096 and 16384."
  }
}

variable "master_disk_size" {
  type        = number
  default     = 100
  description = "The size of the root disk to allocate to each master node."

  validation {
    condition     = var.master_disk_size >= 100 && var.master_disk_size <= 1000
    error_message = "The size of the root disk must be between 100 and 1000."
  }
}

variable "master_additional_disk_size" {
  type        = number
  default     = null
  description = "The size of the additional disk to allocate to each master node."
}

########################################
# Worker
########################################

variable "worker_vm_template" {
  type        = string
  description = "The name of the template to use for the worker nodes."
}

variable "worker_datastores" {
  type        = list(string)
  default     = []
  description = "The datastores to use for the worker nodes."

  validation {
    condition     = length(var.worker_datastores) >= 1
    error_message = "At least one datastore must be specified."
  }
}

variable "worker_cores" {
  type        = number
  default     = 4
  description = "The number of cores to allocate to each worker node."

  validation {
    condition     = var.worker_cores >= 4 && var.worker_cores <= 12
    error_message = "The number of cores must be between 4 and 12."
  }
}

variable "worker_memory" {
  type        = number
  default     = 4096
  description = "The amount of memory to allocate to each worker node."

  validation {
    condition     = var.worker_memory >= 4096 && var.worker_memory <= 32768
    error_message = "The amount of memory must be between 4096 and 32768."
  }
}

variable "worker_disk_size" {
  type        = number
  default     = 100
  description = "The size of the root disk to allocate to each worker node."

  validation {
    condition     = var.worker_disk_size >= 100 && var.worker_disk_size <= 10000
    error_message = "The size of the root disk must be between 100 and 10000."
  }
}

variable "worker_additional_disk_size" {
  type        = number
  default     = null
  description = "The size of the additional disk to allocate to each worker node."
}
