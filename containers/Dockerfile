FROM ghcr.io/pfm-powerforme/s6-deb-php:8.1 AS build

ENV LSK_PRO_VERSION=2.1

RUN apt-get -y update && apt-get -y --no-install-recommends install git composer
WORKDIR /tmp
RUN git -c advice.detachedHead=false clone --branch ${LSK_PRO_VERSION} --depth 1 https://github.com/lsky-org/lsky-pro.git
WORKDIR /tmp/lsky-pro
RUN rm -rf .git && rm -rf .github
RUN sed -i "s/PRC/Asia\/Shanghai/g" config/app.php
RUN composer install
RUN rm -rf .env＊


FROM ghcr.io/pfm-powerforme/s6-deb-php:8.1

ENV CADDY_WORK_DIR=/var/www/lsky-pro/public

# ROOTFS
COPY containers/rootfs /

COPY --from=build /tmp/lsky-pro /var/www/lsky-pro

RUN /usr/local/sbin/fix_mod

WORKDIR /var/www/lsky-pro

VOLUME /var/www/lsky-pro/storage/app

HEALTHCHECK --timeout=60s CMD netstat -tulnp | grep -q ':80\b' && exit 0 || exit 1
