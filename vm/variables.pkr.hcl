variable "vm_name" {
  type        = string
  default     = "mrs-sdk-qt"
  description = "Base name for the VM and output file"
}

variable "vm_memory" {
  type        = number
  default     = 4096
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
  default     = "https://releases.ubuntu.com/24.04/ubuntu-24.04.1-live-server-amd64.iso"
  description = "URL to Ubuntu 24.04 LTS ISO"
}

variable "iso_checksum" {
  type        = string
  default     = "file:https://releases.ubuntu.com/24.04/SHA256SUMS"
  description = "Checksum for ISO verification"
}

variable "output_directory" {
  type        = string
  default     = "output"
  description = "Directory where OVA will be written"
}

variable "build_date" {
  type        = string
  default     = ""
  description = "Build date in YYYYMMDD format (auto-generated if empty)"
}

locals {
  # Auto-generate build date if not provided
  build_date = var.build_date != "" ? var.build_date : formatdate("YYYYMMDD", timestamp())
  
  # Generate OVA filename with date
  output_filename = "${var.vm_name}-${local.build_date}.ova"
}
