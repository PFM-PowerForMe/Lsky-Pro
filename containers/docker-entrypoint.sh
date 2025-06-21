#!/usr/bin/env bash
set -Eeuo pipefail

if [ ! -e '/var/www/html/public/index.php' ]; then
    cp -a /usr/src/lsky-pro/* /var/www/html/
    cp -a /usr/src/lsky-pro/.env.example /var/www/html/
    chown -R www-data:www-data /var/www/html
    chmod -R 755 /var/www/html/
else
    chown -R www-data:www-data /var/www/html
    chmod -R 755 /var/www/html/
fi

if [ -e '/var/www/html/.env' ]; then
    if [ -n "${REDIS_ENABLE}" ]; then
    	E_REDIS_HOST="${REDIS_HOST:-127.0.0.1}"
    	E_REDIS_PASSWORD="${REDIS_PASSWORD:-null}"
    	E_REDIS_PORT=${REDIS_PORT:-6379}
    	sed -i "s/^CACHE_DRIVER=.*/CACHE_DRIVER=redis/" /var/www/html/.env
    	sed -i "s/^SESSION_DRIVER=.*/SESSION_DRIVER=redis/" /var/www/html/.env
    	sed -i "s|^REDIS_HOST=.*|REDIS_HOST=${E_REDIS_HOST}|" /var/www/html/.env
    	sed -i "s|^REDIS_PASSWORD=.*|REDIS_PASSWORD=${E_REDIS_PASSWORD}|" /var/www/html/.env
    	sed -i "s/^REDIS_PORT=.*/REDIS_PORT=${E_REDIS_PORT}/" /var/www/html/.env
    else
    	sed -i "s/^CACHE_DRIVER=.*/CACHE_DRIVER=file/" /var/www/html/.env
    	sed -i "s/^SESSION_DRIVER=.*/SESSION_DRIVER=file/" /var/www/html/.env
    fi
    if [ -n "${APP_URL}" ]; then
    	sed -i "s|^APP_URL=.*|APP_URL=${APP_URL}|" /var/www/html/.env
    else
    	sed -i "s/^APP_URL=.*/APP_URL=http://localhost/" /var/www/html/.env
    fi
fi

exec "$@"