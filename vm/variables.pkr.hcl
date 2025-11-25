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
  default     = "https://releases.ubuntu.com/24.04/ubuntu-24.04.3-desktop-amd64.iso"
  description = "URL to Ubuntu 24.04 LTS Desktop ISO"
}

variable "iso_checksum" {
  type        = string
  default     = "sha256:faabcf33ae53976d2b8207a001ff32f4e5daae013505ac7188c9ea63988f8328"
  description = "Checksum for ISO verification"
}

variable "build_date" {
  type        = string
  default     = ""
  description = "Build date in YYYYMMDD format (optional, for tracking purposes)"
}
