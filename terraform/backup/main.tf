terraform {
  required_providers {
    proxmox = {
      source  = "telmate/proxmox"
      version = "3.0.2-rc04"
    }
  }
}

provider "proxmox" {
  pm_api_url          = "https://192.168.190.137:8006/api2/json"
  pm_api_token_id     = "root@pam!terraform-paas"
  pm_api_token_secret = "7f650da5-1ac5-48e3-ba5c-fa7880a7e1fe"
  pm_tls_insecure     = true
}

resource "proxmox_vm_qemu" "test_template" {
  name        = "test-template-fix"
  target_node = "pve"
  
  # Try with your new template name
  clone = "ubuntu-20-04-fixed-template"
  
  # OR if you kept the old name but fixed it
  # clone = "ubuntu-20-04-server-template"
  
  # Minimal config
  cpu {
    cores = 1
  }
  
  memory = 1024  # Small for testing
  agent  = 1     # Enable agent to test if it works
  
  disk {
    size    = "10G"
    storage = "local-lvm"
    type    = "scsi"
  }
  
  network {
    model  = "virtio"
    bridge = "vmbr0"
  }
  
  # Cloud-init
  ciuser     = "ubuntu"
  cipassword = "ubuntu"
}

output "test_result" {
  value = "Testing template: ${proxmox_vm_qemu.test_template.clone}"
}

output "vm_id" {
  value = proxmox_vm_qemu.test_template.vmid
}