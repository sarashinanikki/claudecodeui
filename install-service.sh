#!/bin/bash

# Installation script for Claude Code UI systemd service
# Run this script with sudo on your Linux server

set -e

# Configuration
SERVICE_NAME="claude-code-ui"
INSTALL_DIR="/opt/claude-code-ui"
SERVICE_USER="claude-ui"
SERVICE_GROUP="claude-ui"

echo "Installing Claude Code UI as systemd service..."

# Create service user
if ! id "$SERVICE_USER" &>/dev/null; then
    echo "Creating service user: $SERVICE_USER"
    useradd --system --shell /bin/false --home-dir "$INSTALL_DIR" --create-home "$SERVICE_USER"
fi

# Create installation directory
echo "Creating installation directory: $INSTALL_DIR"
mkdir -p "$INSTALL_DIR"

# Copy files
echo "Copying application files..."
rsync -av --exclude=node_modules --exclude=.git . "$INSTALL_DIR/"

# Install dependencies
echo "Installing npm dependencies..."
cd "$INSTALL_DIR"
npm ci --production

# Set permissions
echo "Setting file permissions..."
chown -R "$SERVICE_USER:$SERVICE_GROUP" "$INSTALL_DIR"
chmod +x "$INSTALL_DIR/scripts/start-with-ngrok.sh"

# Update service file with correct user
sed -i "s/User=www-data/User=$SERVICE_USER/" "$INSTALL_DIR/systemd/claude-code-ui.service"
sed -i "s/Group=www-data/Group=$SERVICE_GROUP/" "$INSTALL_DIR/systemd/claude-code-ui.service"

# Install service file
echo "Installing systemd service..."
cp "$INSTALL_DIR/systemd/claude-code-ui.service" "/etc/systemd/system/"

# Reload systemd and enable service
echo "Enabling and starting service..."
systemctl daemon-reload
systemctl enable "$SERVICE_NAME"
systemctl start "$SERVICE_NAME"

echo "Installation complete!"
echo ""
echo "Service status:"
systemctl status "$SERVICE_NAME" --no-pager
echo ""
echo "To view logs: journalctl -u $SERVICE_NAME -f"
echo "To restart: sudo systemctl restart $SERVICE_NAME"
echo "To stop: sudo systemctl stop $SERVICE_NAME"
echo ""
echo "IMPORTANT: Set your ngrok auth token:"
echo "1. Edit /etc/systemd/system/claude-code-ui.service"
echo "2. Set Environment=NGROK_AUTH_TOKEN=your_token_here"
echo "3. Run: sudo systemctl daemon-reload && sudo systemctl restart $SERVICE_NAME"