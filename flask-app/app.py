from flask import Flask, render_template, request, jsonify
import subprocess
import os
import json
import time
import sys
import os
sys.path.append(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
app = Flask(__name__)
app.config.from_object('config.Config')
@app.route('/')
def index():
    
    return render_template('index.html')

@app.route('/deploy', methods=['POST'])
def deploy():
    try:
        data = request.json
        
        # Get user inputs
        vm_name = data.get('vm_name', f"app-{int(time.time())}")
        framework = data.get('framework', 'django')
        git_repo = data.get('git_repo')
        
        if not git_repo:
            return jsonify({'error': 'Git repository URL is required'}), 400
        
        print(f"🚀 Starting deployment: {vm_name} ({framework}) from {git_repo}")
        
        # Create terraform.tfvars
        tfvars_content = f'''vm_name = "{vm_name}"
framework = "{framework}"
git_repo = "{git_repo}"'''
        
        with open('../terraform/terraform.tfvars', 'w') as f:
            f.write(tfvars_content)
        
        # Run Terraform
        os.chdir('../terraform')
        
        # Initialize (if needed)
        subprocess.run(['terraform', 'init'], capture_output=True, text=True)
        
        # Apply
        result = subprocess.run(
            ['terraform', 'apply', '-auto-approve', '-var-file=terraform.tfvars'],
            capture_output=True,
            text=True,
            timeout=300  # 5 minutes
        )
        
        # Get outputs
        output_result = subprocess.run(
            ['terraform', 'output', '-json'],
            capture_output=True,
            text=True
        )
        
        os.chdir('../flask-app')
        
        # Parse outputs
        outputs = {}
        if output_result.returncode == 0:
            try:
                outputs = json.loads(output_result.stdout)
            except:
                pass
        
        # Check success
        if result.returncode == 0 or "Creation complete" in result.stdout:
            vm_id = outputs.get('vm_info', {}).get('value', {}).get('id', 'unknown')
            
            return jsonify({
                'success': True,
                'message': '✅ VM deployed successfully!',
                'details': {
                    'vm_name': vm_name,
                    'vm_id': vm_id,
                    'framework': framework,
                    'git_repo': git_repo,
                    'proxmox_url': f'https://192.168.190.137:8006/#v1:0:node/pve/qemu/{vm_id}',
                    'status': 'VM created. Framework installation pending.'
                }
            })
        else:
            return jsonify({
                'error': 'Terraform deployment failed',
                'details': result.stderr[:500] if result.stderr else result.stdout[:500]
            }), 500
            
    except subprocess.TimeoutExpired:
        return jsonify({
            'success': True,  # Still consider it success
            'message': '⚠️ VM creation in progress (timeout)',
            'note': 'Check Proxmox Web UI manually. The VM is likely being created.'
        })
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@app.route('/list_vms')
def list_vms():
    
    try:
        os.chdir('../terraform')
        
        # Get current state
        result = subprocess.run(
            ['terraform', 'state', 'list'],
            capture_output=True,
            text=True
        )
        
        os.chdir('../flask-app')
        
        vms = []
        if result.returncode == 0:
            for line in result.stdout.strip().split('\n'):
                if 'proxmox_vm_qemu' in line:
                    vms.append(line.split('.')[-1])
        
        return jsonify({'vms': vms})
        
    except Exception as e:
        return jsonify({'error': str(e)}), 500

if __name__ == '__main__':
    app.run(debug=True, host='0.0.0.0', port=5000)