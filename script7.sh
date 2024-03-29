#!/bin/bash

# Action "user": Création d'un nouvel utilisateur avec un mot de passe
create_user() {
    username=$1
    password=$2
    sudo useradd -m $username
    echo "$username:$password" | sudo chpasswd
}

# Action "install": Mise à jour des dépôts et installation de nginx
install_nginx() {
    sudo apt update
    sudo apt install nginx -y
}

# Action "configure_site": Ajout d'une configuration nginx pour un nouveau site
configure_site() {
    sitename=$1
    port=$2
    sudo cp nginx_template.conf /etc/nginx/sites-available/$sitename
    sudo sed -i "s/listen 8083/listen $port/" /etc/nginx/sites-available/$sitename
    sudo sed -i "s/server_name monsupersite/server_name $sitename/" /etc/nginx/sites-available/$sitename
    sudo sed -i "s@root /var/www/monsupersite@root /var/www/$sitename@" /etc/nginx/sites-available/$sitename
    sudo ln -s /etc/nginx/sites-available/$sitename /etc/nginx/sites-enabled/
    sudo systemctl reload nginx
    sudo mkdir -p /var/www/$sitename
    echo "<html><body><h1>$sitename</h1></body></html>" | sudo tee /var/www/$sitename/index.html >/dev/null
}

# Action "active_site": Activation d'un site nginx
activate_site() {
    sitename=$1
    sudo ln -s /etc/nginx/sites-available/$sitename /etc/nginx/sites-enabled/
    sudo systemctl reload nginx
}

# Action "add_cronjob": Ajout d'une tâche cron
add_cronjob() {
    (crontab -l ; echo "*/5 * * * * echo 'helloworld' >> /path/to/your/file.txt") | crontab -
}

# Action "generate_ssh": Génération d'une clé SSH RSA de 4096 bits
generate_ssh() {
    ssh-keygen -t rsa -b 4096
}

# Action "configure_php_site": Configuration d'un site PHP
configure_php_site() {
    sitename=$1
    port=$2
    configure_site $sitename $port
    sudo apt install php-fpm php-mysql -y
}

# Action "install": Installation de nginx, PHP et MySQL
install() {
    install_nginx
    sudo apt install php php-mysql mysql-server -y
}

# Action "add_cronjob": Surveiller l'espace disque et envoyer un message à Slack si l'espace disque est inférieur à 10%
add_cronjob_with_disk_monitoring() {
    (crontab -l ; echo "*/5 * * * * /path/to/disk_monitor.sh") | crontab -
}

send_slack_message() {
    message=$1
    curl -X POST -H 'Content-type: application/json' --data "{\"text\":\"$message\"}" https://hooks.slack.com/services/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
}

# Main
if [ "$1" = "user" ]; then
    create_user "$2" "$3"
elif [ "$1" = "install" ]; then
    install
elif [ "$1" = "configure_site" ]; then
    configure_site "$2" "$3"
elif [ "$1" = "active_site" ]; then
    activate_site "$2"
elif [ "$1" = "add_cronjob" ]; then
    add_cronjob
elif [ "$1" = "generate_ssh" ]; then
    generate_ssh
elif [ "$1" = "configure_php_site" ]; then
    configure_php_site "$2" "$3"
elif [ "$1" = "add_cronjob_with_disk_monitoring" ]; then
    add_cronjob_with_disk_monitoring
elif [ "$1" = "send_slack_message" ]; then
    send_slack_message "$2"
else
    echo "Action not recognized"
fi
