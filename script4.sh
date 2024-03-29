#!/bin/bash

creer_utilisateur() {
    if [ $# -ne 3 ]; then
        echo "Utilisation : $0 user nom_utilisateur mot_de_passe"
        exit 1
    fi

    local nom_utilisateur=$2
    local mot_de_passe=$3

    if id "$nom_utilisateur" &>/dev/null; then
        echo "L'utilisateur $nom_utilisateur existe déjà."
        exit 1
    fi

    useradd -m $nom_utilisateur
    echo "$nom_utilisateur:$mot_de_passe" | chpasswd
    echo "L'utilisateur $nom_utilisateur a été créé avec le mot de passe $mot_de_passe"
}

installer_nginx() {
    apt update
    apt install -y nginx
    echo "Nginx a été installé avec succès"
}

configurer_site() {
    if [ $# -ne 2 ]; then
        echo "Utilisation : $0 configure_site nom_du_site"
        exit 1
    fi

    local nom_du_site=$2

    local config_file="/etc/nginx/sites-available/$nom_du_site"
    local root_directory="/var/www/$nom_du_site"
    local index_file="$root_directory/index.html"

    cp /etc/nginx/sites-available/default $config_file
    sed -i "s/server_name _/server_name $nom_du_site;/" $config_file

    echo "server {
        listen 8083 default_server;
        listen [::]:8083 default_server;

        root $root_directory;

        index index.html;

        server_name $nom_du_site;

        location / {
            # First attempt to serve request as file, then
            # as directory, then fall back to displaying a 404.
            try_files \$uri \$uri/ =404;
        }
    }" | tee $config_file > /dev/null

    mkdir -p $root_directory
    echo "<html><body>Bienvenue sur $nom_du_site</body></html>" | tee $index_file > /dev/null

    echo "Le fichier de configuration pour le site $nom_du_site a été créé dans $config_file"
}

case $1 in
    user)
        creer_utilisateur "$@"
        ;;
    install)
        installer_nginx
        ;;
    configure_site)
        configurer_site "$@"
        ;;
    *)
        echo "Option invalide. Veuillez choisir parmi : user, install, configure_site"
        exit 1
        ;;
esac

exit 0
