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
