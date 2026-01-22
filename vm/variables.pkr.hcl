# Packer variables for VM configuration
# Override via CLI: packer build -var "vm_memory=8192" .
# Override via env: PKR_VAR_vm_memory=8192 packer build .

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

variable "accelerator" {
  type        = string
  default     = "kvm"
  description = "QEMU accelerator to use (kvm for local, tcg for CI/cloud)"
}

variable "build_timeout" {
  type        = string
  default     = "60m"
  description = "SSH timeout for Packer to wait for the VM to become available (e.g., 60m, 120m)"
}

# NOTE: this variable is used only in CI. It is not relevant for local builds.
variable "version" {
  type        = string
  default     = "latest"
  description = "Version tag for the VM image"
}
