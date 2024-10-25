#!/bin/bash
set -x  # Activer le mode debug

function setup_2fa {
    # Vérifier si libpam-google-authenticator est déjà installé
    if ! dpkg -l | grep -q libpam-google-authenticator; then
        echo "Installation de libpam-google-authenticator..."
        sudo apt-get update
        sudo apt-get install libpam-google-authenticator -y
    else
        echo "libpam-google-authenticator est déjà installé."
    fi

    # Configurer Google Authenticator pour l'utilisateur actuel
    echo "Configuration de Google Authenticator pour l'utilisateur $(whoami)..."
    google-authenticator -t -d -f -r 3 -R 30 -W

    # Modifier la configuration PAM pour SSH
    echo "Modification de /etc/pam.d/sshd pour ajouter Google Authenticator..."
    if ! grep -q "pam_google_authenticator.so" /etc/pam.d/sshd; then
        sudo sed -i 's/@include common-auth/#@include common-auth/' /etc/pam.d/sshd
        echo "auth required pam_google_authenticator.so" | sudo tee -a /etc/pam.d/sshd
    else
        echo "Google Authenticator est déjà configuré dans PAM."
    fi

    # Activer KbdInteractiveAuthentication et définir AuthenticationMethods dans sshd_config
    echo "Modification de /etc/ssh/sshd_config pour autoriser KbdInteractiveAuthentication et configurer AuthenticationMethods..."
    sudo sed -i 's/^#*KbdInteractiveAuthentication no/KbdInteractiveAuthentication yes/' /etc/ssh/sshd_config

    # Ajouter AuthenticationMethods publickey,keyboard-interactive si absent
    if ! grep -q "^AuthenticationMethods publickey,keyboard-interactive" /etc/ssh/sshd_config; then
        echo "AuthenticationMethods publickey,keyboard-interactive" | sudo tee -a /etc/ssh/sshd_config
    else
        echo "AuthenticationMethods publickey,keyboard-interactive est déjà configuré."
    fi

    # Redémarrer le service SSH
    echo "Redémarrage du service SSH pour appliquer les modifications..."
    sudo systemctl restart ssh

    echo "Authentification à deux facteurs activée pour SSH."
}

# Appeler la fonction
setup_2fa
