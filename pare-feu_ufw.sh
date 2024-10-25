#!/bin/bash

# Installation de UFW
sudo apt update
sudo apt install ufw -y

# Autoriser les connexions SSH
sudo ufw allow ssh

# Demander l'autorisation pour HTTP et HTTPS si nécessaire
read -p "Autoriser HTTP et HTTPS (y/n) ? " response
if [[ "$response" =~ ^[Yy]$ ]]; then
    sudo ufw allow http
    sudo ufw allow https
fi

# Bloquer tout le reste par défaut
sudo ufw default deny incoming
sudo ufw default allow outgoing

# Activer UFW avec confirmation
echo "y" | sudo ufw enable

# Vérifier le statut du pare-feu
sudo ufw status verbose
