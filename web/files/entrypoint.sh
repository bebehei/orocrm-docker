#!/bin/bash

export LETSENCRYPT=${LETSENCRYPT:-0}

set -euo pipefail

PID_NGINX=/run/nginx/nginx.pid
PID_FPM=/run/php/php-fpm.pid

export SSL_KEY=/certs/ssl.key
export SSL_CRT=/certs/ssl.crt

exit_handler(){
	kill $(cat ${PID_FPM})
	nginx -s quit
	while [ -e ${PID_NGINX} ]; do
		sleep 0.1
	done
}

trap exit_handler TERM QUIT

acme_cron(){
	while sleep $(( 60 * 60 * 24 )); do
		certbot -c ${INSTALLDIR}/letsencrypt.ini renew -d "${DOMAIN}"
	done
}

! [ "${LETSENCRYPT}" == '1' ] \
	|| [ -n "${DOMAIN+x}" ] \
	|| { echo "Letsencrypt activated, but no domain set."; exit 1; }

export DOMAIN=${DOMAIN:-$(hostname --fqdn)}

sed -i "
    s/database_host:.*/database_host: ${ORO_DB_HOST:-null}/;
    s/database_port:.*/database_port: ${ORO_DB_PORT:-null}/;
    s/database_name:.*/database_name: ${ORO_DB_NAME:-null}/;
    s/database_user:.*/database_user: ${ORO_DB_USER:-null}/;
    s/database_password:.*/database_password: ${ORO_DB_PASS:-null}/;
    s/locale:.*/locale: ${ORO_LOCALE:-en}/;
    s/installed:.*/installed: ${ORO_INSTALLED:-null}/;
    s/secret:.*/secret: ${ORO_SECRET:-null}/;
" ${INSTALLDIR}/src/app/config/parameters.yml

# start basic php fpm server
mkdir -p $(dirname "${PID_FPM}") 
php-fpm7.1 -F --pid ${PID_FPM} &

# force remove old configuration
# a container restart may still contain it
rm -f /etc/nginx/conf.d/*

# start basic nginx server
mkdir -p $(dirname "${PID_NGINX}") 
envsubst < ${INSTALLDIR}/nginx.template.http \
         > /etc/nginx/conf.d/http.conf
nginx

# crawl letsencrypt certs
if [ "${LETSENCRYPT}" == '1' ]; then
	mkdir -p /run/le-webroot

	if ! [ -e "/etc/letsencrypt/live/${DOMAIN}/privkey.pem" ]; then
		certbot -c ${INSTALLDIR}/letsencrypt.ini certonly \
			--agree-tos --register-unsafely-without-email \
			-d "${DOMAIN}"
	else
		echo "Letsencrypt certificate is available"
	fi

	acme_cron &

	export SSL_CRT="/etc/letsencrypt/live/${DOMAIN}/fullchain.pem"
	export SSL_KEY="/etc/letsencrypt/live/${DOMAIN}/privkey.pem"
fi

# enable HTTPS
if   [ -r "${SSL_CRT}" ] \
	&& [ -r "${SSL_KEY}" ]; then
	envsubst < ${INSTALLDIR}/nginx.template.https \
	         > /etc/nginx/conf.d/https.conf
	nginx -s reload
fi

touch /var/log/nginx/orocrm.log
tail -f /var/log/nginx/orocrm.log &

oro-console fos:js-routing:dump
oro-console oro:localization:dump
oro-console oro:assets:install
oro-console assetic:dump
oro-console oro:requirejs:build
oro-console cache:clear
oro-console oro:translation:dump
oro-console oro:language:update --language=${ORO_LOCALE:-en}

wait
