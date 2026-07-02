variable "vm_name" {
  description = "Name of the VM"
  type        = string
}

variable "framework" {
  description = "Framework to install"
  type        = string
}

variable "git_repo" {
  description = "GitHub repository URL"
  type        = string
}

variable "vm_id" {
  description = "VM ID (optional, auto-assigned if empty)"
  type        = number
  default     = null
}