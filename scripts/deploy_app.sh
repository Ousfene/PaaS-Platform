#!/bin/bash

# Deploy application from Git repository
GIT_REPO=$1
FRAMEWORK=$2
APP_DIR="/home/ubuntu/app"

echo "Deploying application from $GIT_REPO"

# Update system
sudo apt-get update

# Clone repository
sudo rm -rf $APP_DIR
git clone $GIT_REPO $APP_DIR
cd $APP_DIR

# Install framework-specific dependencies
case $FRAMEWORK in
    "django")
        pip3 install -r requirements.txt
        # Run migrations if manage.py exists
        if [ -f "manage.py" ]; then
            python3 manage.py migrate
            python3 manage.py collectstatic --noinput
        fi
        # Start with gunicorn
        nohup gunicorn --bind 0.0.0.0:8000 $(basename $APP_DIR).wsgi:application > app.log 2>&1 &
        echo "Django app running on port 8000"
        ;;
    "flask")
        pip3 install -r requirements.txt
        # Find the main app file
        APP_FILE=$(find . -name "*.py" -type f | head -1)
        nohup python3 $APP_FILE > app.log 2>&1 &
        echo "Flask app running"
        ;;
    "nodejs")
        npm install
        # Start with PM2
        pm2 start npm --name "app" -- start
        pm2 save
        pm2 startup
        echo "Node.js app running"
        ;;
    *)
        echo "Framework deployment not configured: $FRAMEWORK"
        ;;
esac

echo "Application deployed to $APP_DIR"
echo "Check logs at: $APP_DIR/app.log"