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

resource "proxmox_vm_qemu" "paas_vm" {
  name        = var.vm_name
  target_node = "pve"
  vmid        = var.vm_id
  
  # Use the NEW fixed template
  clone = "ubuntu-20-04-fixed-template"
  
  # Correct CPU syntax (no warnings)
  cpu {
    cores   = 2
    sockets = 1
  }
  
  memory  = 2048
  agent   = 0  # Keep disabled to avoid warnings
  
  disks {
    scsi {
      scsi0 {
        disk {
          storage = "local-lvm"
          size    = "20G"
        }
      }
    }
  }
  
  network {
    model  = "virtio"
    bridge = "vmbr0"
    id     = 0
  }
  
  # Cloud-init configuration
  ciuser     = "ubuntu"
  cipassword = "ubuntu"
  ipconfig0  = "ip=dhcp"
  onboot     = true
  
  # Don't wait for agent connection
  define_connection_info = false
}

# Outputs
output "vm_info" {
  value = {
    name = proxmox_vm_qemu.paas_vm.name
    id   = proxmox_vm_qemu.paas_vm.vmid
    node = proxmox_vm_qemu.paas_vm.target_node
  }
}

output "proxmox_url" {
  value = "https://192.168.190.137:8006/#v1:0:node/pve/qemu/${proxmox_vm_qemu.paas_vm.vmid}"
}

output "deployment_status" {
  value = "VM created successfully. Check Proxmox Web UI for IP address."
}