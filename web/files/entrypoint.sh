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
		certbot -c ${INSTALLDIR}/letsencrypt.ini renew --test-cert -d "${DOMAIN}"
	done
}

! [ "${LETSENCRYPT}" == '1' ] \
	|| [ -n "${DOMAIN+x}" ] \
	|| { echo "Letsencrypt activated, but no domain set."; exit 1; }

export DOMAIN=${DOMAIN:-$(hostname --fqdn)}

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
	certbot -c ${INSTALLDIR}/letsencrypt.ini certonly --test-cert \
		--agree-tos --register-unsafely-without-email \
		-d "${DOMAIN}"

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

wait
