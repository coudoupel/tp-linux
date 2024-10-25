#!/bin/bash

# Installation de unattended-upgrades
sudo apt update
sudo apt install unattended-upgrades -y

# Configurer unattended-upgrades pour activer les mises à jour automatiques de sécurité
sudo dpkg-reconfigure --priority=low unattended-upgrades

# Activer uniquement les mises à jour de sécurité avec redémarrage automatique
sudo bash -c 'cat > /etc/apt/apt.conf.d/50unattended-upgrades' << EOL
Unattended-Upgrade::Origins-Pattern {
    "o=Debian,a=\${distro_codename}-security";
};

Unattended-Upgrade::Automatic-Reboot "true";
Unattended-Upgrade::Automatic-Reboot-Time "02:00";
EOL

echo "Mises à jour automatiques de sécurité activées sans notifications."
