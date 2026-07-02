variable "vm_name" {
  description = "Name of the VM to create"
  type        = string
  default     = "test-app-2"
}

variable "framework" {
  description = "Framework to install (django, flask, nodejs, laravel)"
  type        = string
  default     = "django"
}

variable "git_repo" {
  description = "GitHub repository URL to clone"
  type        = string
  default     = "https://github.com/example/django-app.git"
}

variable "vm_id" {
  description = "VM ID to assign (auto if not specified)"
  type        = number
  default     = null
}