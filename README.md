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

### Suggestions d'Idées Supplémentaires

Poussez encore plus loin la personnalisation et la sécurisation en réfléchissant à d’autres fonctionnalités ou scripts qui pourraient améliorer votre système. 
Réfléchissez aux tâches que vous effectuez souvent, aux aspects de la sécurité que vous pourriez renforcer, ou aux améliorations que vous aimeriez avoir dans votre environnement de travail. Soyez créatifs !
