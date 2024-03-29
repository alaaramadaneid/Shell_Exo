#!/bin/bash

if [ "$1" = "user" ]; then
    if [ $# -ne 3 ]; then
        echo "Usage: $0 user username password"
        exit 1
    fi
    
    username="$2"
    password="$3"
    echo "Création de l'utilisateur : $username"
    useradd "$username" --create-home
    
    echo "$username:$password" | chpasswd
    
    echo "Utilisateur créé : $username"
    echo "Mot de passe enregistré : $password"
elif [ "$1" = "install" ]; then
    echo "Mise à jour des référentiels..."
    apt update
    echo "Installation du paquet nginx..."
    apt install nginx
    echo "Nginx installé avec succès."
elif [ "$1" = "configure_site" ]; then
    if [ $# -ne 2 ]; then
        echo "Usage: $0 configure_site site_name"
        exit 1
    fi
    
    site_name="$2"
    echo "Création du fichier de configuration pour le site : $site_name"
    touch "/etc/nginx/sites-available/$site_name"
    echo "Fichier de configuration créé : /etc/nginx/sites-available/$site_name"
else
    echo "Argument invalide. Utilisation :"
    echo "Pour créer un utilisateur : ./script3 user nom_utilisateur mot_de_passe"
    echo "Pour installer nginx : ./script3 install"
    echo "Pour configurer un nouveau site : ./script3 configure_site nom_du_site"
fi
