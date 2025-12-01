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

variable "iso_url" {
  type        = string
  default     = "https://releases.ubuntu.com/noble/ubuntu-24.04.3-live-server-amd64.iso"
  description = "URL to Ubuntu 24.04 LTS Server ISO"
}

variable "iso_checksum" {
  type        = string
  default     = "sha256:c3514bf0056180d09376462a7a1b4f213c1d6e8ea67fae5c25099c6fd3d8274b"
  description = "Checksum for ISO verification"
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
