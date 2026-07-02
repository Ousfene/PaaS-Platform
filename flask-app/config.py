import os

class Config:
    SECRET_KEY = os.environ.get('SECRET_KEY') or 'dev-secret-key'
    PROXMOX_API_URL = "https://192.168.190.137:8006/api2/json"
    PROXMOX_TOKEN_ID = "root@pam!terraform-paas"
    PROXMOX_TOKEN_SECRET = "7f650da5-1ac5-48e3-ba5c-fa7880a7e1fe"
    TERRAFORM_PATH = os.path.join(os.path.dirname(__file__), '../terraform')
    SCRIPTS_PATH = os.path.join(os.path.dirname(__file__), '../scripts')