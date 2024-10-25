#!/bin/bash

# Fonction pour vérifier le statut d'une commande
check_status() {
    if [ $? -ne 0 ]; then
        echo "Échec à l'étape : $1"
        exit 1
    else
        echo "Succès à l'étape : $1"
    fi
}

# Étape 1 : Copie de la clé SSH
echo "Lancement de la copie de la clé SSH..."
./copy_ssh_key.sh
check_status "Copie de la clé SSH"

# Étape 2 : Durcissement de SSH
echo "Lancement du durcissement de SSH..."
sudo ./durcissement_ssh.sh
check_status "Durcissement de SSH"

# Étape 3 : Installation et configuration du pare-feu UFW
echo "Lancement de l'installation et configuration de UFW..."
sudo ./parefeu_ufw.sh
check_status "Installation et configuration du pare-feu UFW"

# Étape 4 : Désactivation des services inutiles
echo "Désactivation des services inutiles..."
sudo ./desactivation_services_inutile.sh
check_status "Désactivation des services inutiles"

echo "Lancement du script des maj auto..."
sudo ./maj_automatique.sh
check_status "Mise à jour automatiques activer"

echo "Création d'alias..."
./creation_alias.sh
check_status "Création d'alias fréquents"

echo "Personnalisation du prompt..."
./personnalisation_prompt.sh
check_status "Personnalisation du prompt Bash"

echo "Création de l’authentification à 2 facteurs..."
./2FA.sh
check_status "Mise en place de google authenticator”
echo "Toutes les étapes ont été exécutées avec succès !"
