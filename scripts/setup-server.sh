#!/bin/bash

# Rotax Server Setup Script
# Bu scripti sunucuda bir kez çalıştırın

set -e

echo "========================================="
echo "🚀 Rotax Server Setup"
echo "========================================="

# Check if running as root
if [ "$EUID" -eq 0 ]; then
  echo "❌ Please run as normal user, not as root"
  exit 1
fi

# Update system
echo "📦 Updating system packages..."
sudo apt update && sudo apt upgrade -y

# Install Docker
echo "🐳 Installing Docker..."
if ! command -v docker &> /dev/null; then
    curl -fsSL https://get.docker.com -o get-docker.sh
    sudo sh get-docker.sh
    sudo usermod -aG docker $USER
    rm get-docker.sh
    echo "✅ Docker installed"
else
    echo "✅ Docker already installed"
fi

# Install Docker Compose
echo "🐳 Installing Docker Compose..."
if ! command -v docker compose &> /dev/null; then
    sudo apt install docker-compose-plugin -y
    echo "✅ Docker Compose installed"
else
    echo "✅ Docker Compose already installed"
fi

# Install Nginx
echo "🌐 Installing Nginx..."
if ! command -v nginx &> /dev/null; then
    sudo apt install nginx -y
    sudo systemctl enable nginx
    echo "✅ Nginx installed"
else
    echo "✅ Nginx already installed"
fi

# Install Certbot (for SSL)
echo "🔒 Installing Certbot..."
if ! command -v certbot &> /dev/null; then
    sudo apt install certbot python3-certbot-nginx -y
    echo "✅ Certbot installed"
else
    echo "✅ Certbot already installed"
fi

# Install Git
echo "📝 Installing Git..."
if ! command -v git &> /dev/null; then
    sudo apt install git -y
    echo "✅ Git installed"
else
    echo "✅ Git already installed"
fi

# Install Google Cloud SDK
echo "☁️  Installing Google Cloud SDK..."
if ! command -v gcloud &> /dev/null; then
    echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] https://packages.cloud.google.com/apt cloud-sdk main" | sudo tee -a /etc/apt/sources.list.d/google-cloud-sdk.list
    curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key --keyring /usr/share/keyrings/cloud.google.gpg add -
    sudo apt update && sudo apt install google-cloud-cli -y
    echo "✅ Google Cloud SDK installed"
else
    echo "✅ Google Cloud SDK already installed"
fi

# Install Fail2ban
echo "🛡️  Installing Fail2ban..."
if ! command -v fail2ban-client &> /dev/null; then
    sudo apt install fail2ban -y
    sudo systemctl enable fail2ban
    sudo systemctl start fail2ban
    echo "✅ Fail2ban installed"
else
    echo "✅ Fail2ban already installed"
fi

# Create project directory
echo "📁 Creating project directory..."
mkdir -p ~/rotax-app
mkdir -p ~/backups

# Create backup script
echo "💾 Creating backup script..."
cat > ~/backup-db.sh << 'EOF'
#!/bin/bash
BACKUP_DIR=~/backups
DATE=$(date +%Y%m%d_%H%M%S)
CONTAINER_NAME=rotax-postgres

mkdir -p $BACKUP_DIR

# Get DB credentials from .env
cd ~/rotax-app
source .env

# Backup database
docker exec $CONTAINER_NAME pg_dump -U $POSTGRES_USER $POSTGRES_DB > $BACKUP_DIR/rotax_$DATE.sql

# Compress backup
gzip $BACKUP_DIR/rotax_$DATE.sql

# Delete backups older than 7 days
find $BACKUP_DIR -name "rotax_*.sql.gz" -mtime +7 -delete

echo "Backup completed: rotax_$DATE.sql.gz"
EOF

chmod +x ~/backup-db.sh

# Setup cron for daily backups
echo "⏰ Setting up daily backup cron job..."
(crontab -l 2>/dev/null; echo "0 2 * * * $HOME/backup-db.sh") | crontab -

# SSH hardening
echo "🔐 Hardening SSH configuration..."
sudo cp /etc/ssh/sshd_config /etc/ssh/sshd_config.backup
sudo sed -i 's/#PermitRootLogin yes/PermitRootLogin no/' /etc/ssh/sshd_config
sudo sed -i 's/#PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config
sudo sed -i 's/PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config

# Firewall setup
echo "🔥 Configuring firewall..."
if ! sudo ufw status | grep -q "Status: active"; then
    sudo ufw default deny incoming
    sudo ufw default allow outgoing
    sudo ufw allow 22/tcp
    sudo ufw allow 80/tcp
    sudo ufw allow 443/tcp
    sudo ufw --force enable
    echo "✅ Firewall configured"
else
    echo "✅ Firewall already active"
fi

echo "========================================="
echo "✅ Server setup completed!"
echo "========================================="
echo ""
echo "Next steps:"
echo "1. Log out and log back in (for Docker group)"
echo "2. Clone your repository to ~/rotax-app"
echo "3. Setup .env file"
echo "4. Configure Nginx"
echo "5. Setup SSL with: sudo certbot --nginx -d yourdomain.com"
echo ""
echo "📖 See DEPLOYMENT_GUIDE.md for detailed instructions"
echo ""
