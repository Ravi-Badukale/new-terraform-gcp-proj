#!/bin/bash
# Update package lists
sudo apt-get update -y

# Install Nginx
sudo apt-get install -y nginx

# Start and enable Nginx service
sudo systemctl start nginx
sudo systemctl enable nginx

# Create a custom index page
echo "Welcome to Nginx on GCP, deployed with Terraform!" | sudo tee /var/www/html/index.html > /dev/null
