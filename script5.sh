#!/bin/bash

create_user() {
    if [ $# -ne 2 ]; then
        echo "Usage: $0 user <username> <password>"
        exit 1
    fi

    local username=$1
    local password=$2

    useradd -m $username
    echo "$username:$password" | chpasswd
    echo "Utilisateur $username créé avec succès."
}

install_nginx() {
    if [ $# -ne 1 ] || [ "$1" != "install" ]; then
        echo "Usage: $0 install"
        exit 1
    fi

    apt update
    apt install -y nginx
    echo "Nginx installé avec succès."
}

configure_site() {
    if [ $# -lt 1 ] || [ $# -gt 2 ]; then
        echo "Usage: $0 configure_site <site_name> [http_port]"
        exit 1
    fi

    local site_name=$1
    local http_port=${2:-80}

    tee /etc/nginx/sites-available/$site_name >/dev/null <<EOF
server {
    listen $http_port default_server;
    listen [::]:$http_port default_server;

    root /var/www/$site_name;

    index index.html;

    server_name $site_name;

    location / {
        try_files \$uri \$uri/ =404;
    }
}
EOF

    mkdir -p /var/www/$site_name
    echo "<h1>$site_name</h1>" | tee /var/www/$site_name/index.html >/dev/null

    echo "Configuration du site $site_name terminée."
}

activate_site() {
    if [ $# -ne 1 ]; then
        echo "Usage: $0 activate_site <site_name>"
        exit 1
    fi

    local site_name=$1

    nginx -t

    ln -s /etc/nginx/sites-available/$site_name /etc/nginx/sites-enabled/
    systemctl reload nginx

    echo "Site $site_name activé avec succès."
}

add_cronjob() {
    local cron_file="/etc/cron.d/helloworld"
    local disk_usage=$(df -h / | awk 'NR==2 {print $5}' | cut -d'%' -f1)

    echo "*/5 * * * * root echo 'helloworld' >> /var/log/helloworld.log" | tee $cron_file >/dev/null

    if [ $disk_usage -gt 90 ]; then
        echo "Disk space almost full $disk_usage% used." | tee -a /var/log/disk_usage.log >/dev/null
    fi

    echo "Tâche cron ajoutée avec succès."
}

if [ $# -lt 1 ]; then
    echo "Usage: $0 <command> [args...]"
    exit 1
fi

case "$1" in
    user)
        create_user "${@:2}"
        ;;
    install)
        install_nginx "${@:2}"
        ;;
    configure_site)
        configure_site "${@:2}"
        ;;
    activate_site)
        activate_site "${@:2}"
        ;;
    add_cronjob)
        add_cronjob "${@:2}"
        ;;
    *)
        echo "Commande inconnue: $1"
        exit 1
        ;;
esac

exit 0
