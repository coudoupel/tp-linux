#!/bin/bash

# Lister les services actifs
echo "Services actifs :"
systemctl list-units --type=service --state=running

# Liste des services potentiellement inutiles
services="avahi-daemon cups bluetooth ModemManager rpcbind nfs-server nfs-common"

# Demander confirmation pour désactiver chaque service
for service in $services; do
    if systemctl is-active --quiet "$service"; then
        read -p "Voulez-vous désactiver le service $service ? (y/n) " response
        if [[ "$response" =~ ^[Yy]$ ]]; then
            sudo systemctl disable "$service"
            sudo systemctl stop "$service"
            echo "Service $service désactivé et arrêté."
        else
            echo "Service $service laissé actif."
        fi
    else
        echo "Service $service n'est pas actif, aucune action nécessaire."
    fi
done
