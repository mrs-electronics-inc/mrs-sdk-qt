variable "vm_name" {
  type        = string
  default     = "mrs-sdk-qt"
  description = "Base name for the VM and output file"
}

variable "vm_memory" {
  type        = number
  default     = 6144
  description = "Amount of RAM in MB to allocate to the VM"
}

variable "vm_cpus" {
  type        = number
  default     = 2
  description = "Number of CPU cores to allocate to the VM"
}

variable "disk_size" {
  type        = number
  default     = 61440
  description = "Disk size in MB (default: 60GB)"
}

variable "version" {
  type        = string
  default     = "latest"
  description = "Version tag for the VM image"
}

variable "accelerator" {
  type        = string
  default     = "kvm"
  description = "QEMU accelerator to use (kvm for local, tcg for CI/cloud)"
}
