# Automatisation et Durcissement d’un Système Debian avec Bash

## Introduction

Nous avons mis en place des scripts d'automatisation pour permettre la sécurisation d'un système Debian.
Nous avons fait :
- La copie de la clé SSH (sur le serveur).
- Durcissement de la connexion via SSH.
- Installation et configuration d'un pare-feu.
- Mise a jour automatique des paquets de sécurité.
- Désactivation des services inutiles.
- Création d'alias pour des commandes fréquentes.
- Personnalisation du prompt Bash.
- 2FA (via google authenticator).
- Script qui éxecute tous les autres.

## Copie de la clé SSH (copy_key_ssh.sh)

```bash
#!/bin/bash

# Vérification de l'existence de la clé SSH
if [ ! -f ~/.ssh/id_rsa ]; then
    echo "Aucune clé SSH trouvée. Création d'une nouvelle paire de clés..."
    ssh-keygen -t rsa -b 4096 -N "" -f ~/.ssh/id_rsa
    echo "Clé SSH créée : ~/.ssh/id_rsa.pub"
else
    echo "Une clé SSH existe déjà : ~/.ssh/id_rsa.pub"
fi

# Afficher la clé publique et l'ajouter à authorized_keys
cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys

# Fixer les permissions du fichier authorized_keys
chmod 600 ~/.ssh/authorized_keys

# Assurer que le répertoire .ssh a les bonnes permissions
chmod 700 ~/.ssh

echo "Clé SSH ajoutée avec succès au fichier authorized_keys."
echo "Clé publique :"
cat ~/.ssh/id_rsa.pub

```

## Durcissement SSH (durcissement_ssh.sh)

```bash
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
```

## Pare-feu (pare-feu_ufw.sh)

```bash
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
```

## Mise à jour automatiques (maj_automatique.sh)

```bash
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
```

## Désactivation des services inutiles (desactivation_services_inutiles.sh)

```bash
#!/bin/bash

# Lister les services actifs
echo "Services actifs :"
systemctl list-units --type=service --state=running

# Demander à l'utilisateur quels services désactiver
read -p "avahi-daemon cups bluetooth ModemManager rpcbind nfs-server nfs-common" services
for service in $services; do
    systemctl disable $service
    systemctl stop $service
    echo "Service $service désactivé."
done
```

## Ajouts d'alias (creation_alias.sh)

```bash
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
```

## Personnalisation du prompt Bash (personnalisation_prompt.sh)

```bash
#!/bin/bash

# Chemin vers le .bashrc de l'utilisateur
USER_BASHRC="$HOME/.bashrc"

# Personnalisation du prompt Bash avec des couleurs si non déjà appliquée
if ! grep -q 'PS1="\\\[\\e[0;32m\\\]\\u@\\h \\\[\\e[0;34m\\\]\\w\\\[\\e[0m\\\] $ "' "$USER_BASHRC"; then
    echo 'PS1="\[\e[0;32m\]\u@\h \[\e[0;34m\]\w\[\e[0m\] $ "' >> "$USER_BASHRC"
    echo "Personnalisation du prompt Bash ajoutée à $USER_BASHRC."
else
    echo "La personnalisation du prompt Bash est déjà présente."
fi

# Recharger le fichier de configuration
source "$USER_BASHRC"

echo "Prompt Bash personnalisé pour l'utilisateur $(whoami)."
```
### Authentification à 2 facteurs (2FA.sh)

```bash
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
```
