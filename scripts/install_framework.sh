#!/bin/bash

# Install framework based on parameter
FRAMEWORK=$1

echo "Installing $FRAMEWORK..."

case $FRAMEWORK in
    "django")
        sudo apt-get update
        sudo apt-get install -y python3 python3-pip python3-venv
        pip3 install django gunicorn
        echo "Django installed successfully"
        ;;
    "flask")
        sudo apt-get update
        sudo apt-get install -y python3 python3-pip python3-venv
        pip3 install flask gunicorn
        echo "Flask installed successfully"
        ;;
    "nodejs")
        sudo apt-get update
        curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
        sudo apt-get install -y nodejs
        npm install -g pm2
        echo "Node.js installed successfully"
        ;;
    "laravel")
        sudo apt-get update
        sudo apt-get install -y php php-cli php-mysql php-mbstring php-xml php-curl
        curl -sS https://getcomposer.org/installer | sudo php -- --install-dir=/usr/local/bin --filename=composer
        composer global require laravel/installer
        echo "Laravel installed successfully"
        ;;
    *)
        echo "Unknown framework: $FRAMEWORK"
        exit 1
        ;;
esac