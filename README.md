# PaaS Platform — Proxmox + Terraform + Flask

A self-hosted Platform-as-a-Service web interface that provisions 
virtual machines on a Proxmox hypervisor and automatically deploys 
web applications from a Git repository.

## What It Does

Enter a VM name, choose a framework, and paste a Git repo URL. 
The platform runs Terraform to clone a VM from a template, then 
installs the chosen framework and deploys your app automatically.

## Supported Frameworks

- Django
- Flask  
- Node.js
- Laravel

## Architecture

├── flask-app/
│   ├── app.py              # POST /deploy, GET /list_vms
│   ├── config.py           # Proxmox connection config
│   └── templates/
│       └── index.html      # Deployment form UI
├── terraform/
│   ├── main.tf             # VM resource definition
│   ├── variables.tf        # vm_name, framework, git_repo
│   └── backup/             # Earlier config versions
└── scripts/
├── install_framework.sh  # Install Django/Flask/Node/Laravel
└── deploy_app.sh         # Clone repo and start app

## VM Specs (Default)

- 2 vCPU, 2GB RAM, 20GB disk
- Cloned from `ubuntu-20-04-fixed-template`
- Cloud-init user: `ubuntu`

## Setup

1. Configure Proxmox API token in `flask-app/config.py`
2. Update Proxmox node IP in `terraform/main.tf`
3. Install dependencies: `pip install flask`
4. Run: `python flask-app/app.py`
5. Open `http://localhost:5000`

> **Note:** Store Proxmox credentials as environment variables 
in production — do not hardcode in config files.
