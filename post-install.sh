#!/bin/bash
set -e

# Add user and prepare virtualenv
useradd -rm homeassistant -G dialout
mkdir -p /srv/homeassistant
chown homeassistant:homeassistant /srv/homeassistant
sudo -u homeassistant -H bash <<EOF
cd /srv/homeassistant
python3 -m venv .
source bin/activate
pip install wheel homeassistant
EOF

# Create Home Assistant systemd unit
cat <<EOF > /etc/systemd/system/home-assistant@homeassistant.service
[Unit]
Description=Home Assistant
After=network-online.target

[Service]
Type=simple
User=homeassistant
WorkingDirectory=/srv/homeassistant
ExecStart=/srv/homeassistant/bin/hass -c "/srv/homeassistant/.homeassistant"
Restart=always

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable home-assistant@homeassistant
systemctl start home-assistant@homeassistant

# Enable services
systemctl enable zoneminder
systemctl start zoneminder
systemctl enable fail2ban
systemctl start fail2ban
systemctl enable cockpit
systemctl start cockpit

# Configure firewall
ufw allow OpenSSH
ufw allow 80,443,8123,9090/tcp
ufw --force enable

# Setup unattended-upgrades
dpkg-reconfigure -f noninteractive unattended-upgrades
