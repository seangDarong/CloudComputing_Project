#!/bin/bash
# =============================================
# user-data.sh — EC2 Startup Script
# =============================================
# This runs AUTOMATICALLY when a new EC2
# instance is created by the ASG.
# It sets up everything needed to run
# the Node.js website.
# =============================================

# Log everything to a file so we can debug
exec > /var/log/user-data.log 2>&1

echo "Starting setup..."

# ── Step 1: Update the system
yum update -y

# ── Step 2: Install Node.js 18
curl -fsSL https://rpm.nodesource.com/setup_18.x | bash -
yum install -y nodejs

# Verify Node.js installed
echo "Node version: $(node --version)"
echo "NPM version: $(npm --version)"

# ── Step 3: Install Git
yum install -y git

# ── Step 4: Clone your website from GitHub
git clone ${github_repo} /app

# ── Step 5: Go into website folder
cd /app/website

# ── Step 6: Install npm packages
npm install

# ── Step 7: Set environment variables
# These replace your .env file on EC2
# Values come from Terraform variables
cat > /app/website/.env << EOF
DB_HOST=${db_host}
DB_NAME=${db_name}
DB_USER=${db_user}
DB_PASSWORD=${db_password}
AWS_REGION=${aws_region}
S3_BUCKET=${s3_bucket}
PORT=3000
EOF

# ── Step 8: Install PM2
# PM2 keeps your Node.js app running
# If it crashes, PM2 restarts it automatically
npm install -g pm2

# ── Step 9: Start the website with PM2
pm2 start app.js --name "student-website"

# ── Step 10: Make PM2 start on reboot
pm2 startup
pm2 save

echo "Setup complete! Website is running."