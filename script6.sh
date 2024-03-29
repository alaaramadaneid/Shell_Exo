#!/bin/bash

create_user() {
    username=$1
    password=$2
    useradd -m $username
    echo "$username:$password" | chpasswd
}

install_nginx() {
    apt update
    apt install -y nginx
}

configure_site() {
    site_name=$1
    port=$2
    cp nginx_template.conf /etc/nginx/sites-available/$site_name
    sed -i "s/listen 8083 default_server/listen $port default_server/g" /etc/nginx/sites-available/$site_name
    sed -i "s/server_name monsupersite/server_name $site_name/g" /etc/nginx/sites-available/$site_name
    sed -i "s#/var/www/default#/var/www/$site_name#g" /etc/nginx/sites-available/$site_name
    mkdir -p /var/www/$site_name
    cp index_template.html /var/www/$site_name/index.html
    nginx -t && systemctl reload nginx
}

active_site() {
    site_name=$1
    ln -s /etc/nginx/sites-available/$site_name /etc/nginx/sites-enabled/
    nginx -t && systemctl reload nginx
}

add_cronjob() {
    echo "*/5 * * * * $(whoami) echo 'helloworld' >> /path/to/your/file.txt" | crontab -
}

generate_ssh() {
    ssh-keygen -t rsa -b 4096
}

configure_php_site() {
    site_name=$1
    cp php_template.conf /etc/nginx/sites-available/$site_name
    sed -i "s/listen 8083 default_server/listen $port default_server/g" /etc/nginx/sites-available/$site_name
    sed -i "s/server_name monsupersite/server_name $site_name/g" /etc/nginx/sites-available/$site_name
    sed -i "s#/var/www/default#/var/www/$site_name#g" /etc/nginx/sites-available/$site_name
    mkdir -p /var/www/$site_name
    cp index.php /var/www/$site_name/index.php
    nginx -t && systemctl reload nginx
}

case "$1" in
    user)
        create_user "$2" "$3"
        ;;
    install)
        install_nginx
        ;;
    configure_site)
        configure_site "$2" "$3"
        ;;
    active_site)
        active_site "$2"
        ;;
    add_cronjob)
        add_cronjob
        ;;
    generate_ssh)
        generate_ssh
        ;;
    configure_php_site)
        configure_php_site "$2"
        ;;
    *)
        echo "Usage: $0 {user|install|configure_site|active_site|add_cronjob|generate_ssh|configure_php_site}"
        exit 1
esac

exit 0
