#!/bin/bash
set -x  # Activer le mode debug


groupadd sshusers
usermod -aG sshusers azerty

function harden_ssh {
    SSH_CONFIG="/etc/ssh/sshd_config"
    
    # Désactiver l'authentification par mot de passe
    sed -i 's/#PasswordAuthentication yes/PasswordAuthentication no/' $SSH_CONFIG
    
    # Désactiver l'accès root via SSH
    sed -i 's/PermitRootLogin yes/PermitRootLogin no/' $SSH_CONFIG
    
    # Limiter l'accès SSH à un groupe spécifique (ex: sshusers)
    echo "AllowGroups sshusers" >> $SSH_CONFIG
    
    # Ajouter une liste blanche d'adresses IP
    echo "sshd : 192.168.38.1 : allow" >> /etc/hosts.allow
    echo "sshd : ALL : deny" >> /etc/hosts.deny

    # Redémarrer SSH pour appliquer les modifications
    systemctl restart ssh

    echo "SSH durci et redémarré."
}

harden_ssh  # Appel de la fonction
