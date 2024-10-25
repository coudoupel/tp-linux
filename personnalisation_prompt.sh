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
