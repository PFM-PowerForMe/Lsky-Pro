# Debian
FROM php:8.0.2-apache

# persistent dependencies
RUN set -eux; \
	apt-get update; \
	rm -rf /var/lib/apt/lists/*

# install the PHP extensions we need (https://make.wordpress.org/hosting/handbook/handbook/server-environment/#php-extensions)
RUN set -ex; \
	\
	savedAptMark="$(apt-mark showmanual)"; \
	\
	apt-get update; \
	### 为版本更新做铺垫 -> php8.2
	# Ctype PHP 扩展
	docker-php-ext-install ctype; \
	# cURL PHP 扩展
	apt-get install -y --no-install-recommends \
		curl libcurl4 libcurl4-openssl-dev \
	; \
	docker-php-ext-install curl; \
	# XML PHP 扩展
	apt-get install -y --no-install-recommends \
		libxml2-dev \
	; \
	docker-php-ext-install xml; \
	# DOM PHP 扩展
	docker-php-ext-install dom; \
	# Fileinfo PHP 扩展
	docker-php-ext-install fileinfo; \
	# Filter PHP 扩展
	\
	# Hash PHP 扩展
	#docker-php-ext-install hash; \
	# Mbstring PHP 扩展
	apt-get install -y --no-install-recommends \
		libonig-dev \
	; \
	docker-php-ext-install mbstring; \
	# OpenSSL PHP 扩展
	\
	# PCRE PHP 扩展
	\
	# PDO PHP 扩展
	apt-get install -y --no-install-recommends \
		libpq-dev libsqlite3-dev libsqlite3-0 \
	; \
	docker-php-ext-install pgsql mysqli pdo pdo_pgsql pdo_mysql pdo_sqlite; \
	# Session PHP 扩展
	docker-php-ext-install session; \
	# Tokenizer PHP 扩展
	docker-php-ext-install tokenizer; \
	# Imagick PHP 拓展
	apt-get install -y --no-install-recommends \
		imagemagick libmagickwand-dev \
	; \
	pecl install imagick; \
	docker-php-ext-enable imagick; \
	rm -r /tmp/pear; \
	# Pcntl PHP 拓展
	docker-php-ext-install pcntl; \
	# Zip PHP 拓展
	apt-get install -y --no-install-recommends \
		libzip-dev \
	; \
	docker-php-ext-install zip; \
	### 开源版 2.0扩展
	# BCMath PHP 扩展
	docker-php-ext-install bcmath; \
	# JSON PHP 扩展
	#docker-php-ext-install json; \
	\
	### Redis
	pecl install redis; \
	docker-php-ext-enable redis; \

# some misbehaving extensions end up outputting to stdout 🙈 (https://github.com/docker-library/wordpress/issues/669#issuecomment-993945967)
	out="$(php -r 'exit(0);')"; \
	[ -z "$out" ]; \
	err="$(php -r 'exit(0);' 3>&1 1>&2 2>&3)"; \
	[ -z "$err" ]; \
	\
	extDir="$(php -r 'echo ini_get("extension_dir");')"; \
	[ -d "$extDir" ]; \
# reset apt-mark's "manual" list so that "purge --auto-remove" will remove all build dependencies
	apt-mark auto '.*' > /dev/null; \
	apt-mark manual $savedAptMark; \
	ldd "$extDir"/*.so \
		| awk '/=>/ { so = $(NF-1); if (index(so, "/usr/local/") == 1) { next }; gsub("^/(usr/)?", "", so); print so }' \
		| sort -u \
		| xargs -r dpkg-query --search \
		| cut -d: -f1 \
		| sort -u \
		| xargs -rt apt-mark manual; \
	\
	apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false; \
	rm -rf /var/lib/apt/lists/*; \
	\
	! { ldd "$extDir"/*.so | grep 'not found'; }; \
# check for output like "PHP Warning:  PHP Startup: Unable to load dynamic library 'foo' (tried: ...)
	err="$(php --version 3>&1 1>&2 2>&3)"; \
	# check
	[ -z "$err" ]
# set recommended PHP.ini settings
# see https://secure.php.net/manual/en/opcache.installation.php
RUN set -eux; \
	docker-php-ext-enable opcache; \
	{ \
		echo 'opcache.memory_consumption=128'; \
		echo 'opcache.interned_strings_buffer=8'; \
		echo 'opcache.max_accelerated_files=4000'; \
		echo 'opcache.revalidate_freq=2'; \
	} > /usr/local/etc/php/conf.d/opcache-recommended.ini
# https://wordpress.org/support/article/editing-wp-config-php/#configure-error-logging
RUN { \
# https://www.php.net/manual/en/errorfunc.constants.php
# https://github.com/docker-library/wordpress/issues/420#issuecomment-517839670
		echo 'error_reporting = E_ERROR | E_WARNING | E_PARSE | E_CORE_ERROR | E_CORE_WARNING | E_COMPILE_ERROR | E_COMPILE_WARNING | E_RECOVERABLE_ERROR'; \
		echo 'display_errors = Off'; \
		echo 'display_startup_errors = Off'; \
		echo 'log_errors = On'; \
		echo 'error_log = /dev/stderr'; \
		echo 'log_errors_max_len = 1024'; \
		echo 'ignore_repeated_errors = On'; \
		echo 'ignore_repeated_source = Off'; \
		echo 'html_errors = Off'; \
	} > /usr/local/etc/php/conf.d/error-logging.ini


RUN set -eux; \
	a2enmod rewrite expires; \
	\
# https://httpd.apache.org/docs/2.4/mod/mod_remoteip.html
	a2enmod remoteip; \
	{ \
		echo 'RemoteIPHeader X-Forwarded-For'; \
# these IP ranges are reserved for "private" use and should thus *usually* be safe inside Docker
		echo 'RemoteIPInternalProxy 10.0.0.0/8'; \
		echo 'RemoteIPInternalProxy 172.16.0.0/12'; \
		echo 'RemoteIPInternalProxy 192.168.0.0/16'; \
		echo 'RemoteIPInternalProxy 169.254.0.0/16'; \
		echo 'RemoteIPInternalProxy 127.0.0.0/8'; \
	} > /etc/apache2/conf-available/remoteip.conf; \
	a2enconf remoteip; \
# https://github.com/docker-library/wordpress/issues/383#issuecomment-507886512
# (replace all instances of "%h" with "%a" in LogFormat)
	find /etc/apache2 -type f -name '*.conf' -exec sed -ri 's/([[:space:]]*LogFormat[[:space:]]+"[^"]*)%h([^"]*")/\1%a\2/g' '{}' +


# 打包
COPY lsky-pro /usr/src/lsky-pro/

RUN ls -al /usr/src/lsky-pro

RUN set -eux; \
	sed -i 's|DocumentRoot /var/www/html|DocumentRoot /var/www/html/public|' /etc/apache2/sites-enabled/000-default.conf

RUN set -eux; \
	# [ ! -e /usr/src/lsky-pro/public/.htaccess ]; \
	{ \
		echo '# BEGIN Lsky-pro'; \
		echo ''; \
		echo 'RewriteEngine On'; \
		echo 'RewriteRule .* - [E=HTTP_AUTHORIZATION:%{HTTP:Authorization}]'; \
		echo 'RewriteBase /'; \
		echo 'RewriteRule ^index\.php$ - [L]'; \
		echo 'RewriteCond %{REQUEST_FILENAME} !-f'; \
		echo 'RewriteCond %{REQUEST_FILENAME} !-d'; \
		echo 'RewriteRule . /index.php [L]'; \
		echo ''; \
		echo '# END Lsky-pro'; \
	} > /usr/src/lsky-pro/public/.htaccess; \
	chown -R www-data:www-data /usr/src/lsky-pro

COPY containers/docker-entrypoint.sh /usr/local/bin/

COPY containers/custom.ini $PHP_INI_DIR/conf.d/

RUN set -eux; \
	chmod +x /usr/local/bin/docker-entrypoint.sh

VOLUME /var/www/html

ENTRYPOINT ["docker-entrypoint.sh"]
CMD ["apache2-foreground"]