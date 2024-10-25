#!/bin/bash

# Chemin vers le .bashrc de l'utilisateur
USER_BASHRC="$HOME/.bashrc"

# Vérifier et créer des alias dans .bashrc de l'utilisateur s'ils n'existent pas déjà
if ! grep -q "alias la='ls -la'" "$USER_BASHRC"; then
    echo "alias la='ls -la'" >> "$USER_BASHRC"
fi

if ! grep -q "alias sr='systemctl restart'" "$USER_BASHRC"; then
    echo "alias sr='systemctl restart'" >> "$USER_BASHRC"
fi

if ! grep -q "alias se='systemctl enable'" "$USER_BASHRC"; then
    echo "alias se='systemctl enable'" >> "$USER_BASHRC"
fi

if ! grep -q "alias update='sudo apt update && sudo apt upgrade -y'" "$USER_BASHRC"; then
    echo "alias update='sudo apt update && sudo apt upgrade -y'" >> "$USER_BASHRC"
fi

# Recharger le fichier de configuration
source ~/.bashrc

echo "Alias créés et activés pour l'utilisateur $(whoami)."
