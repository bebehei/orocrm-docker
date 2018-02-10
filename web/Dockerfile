FROM ubuntu:17.10

RUN export DEBIAN_FRONTEND=noninteractive \
 && set -u \
 && apt-get update \
 && apt-get install -y --no-install-recommends \
      certbot \
      composer \
      gettext \
      git \
      nginx \
      nodejs \
      openssl \
      php7.1 \
      php7.1-ctype \
      php7.1-curl \
      php7.1-dom \
      php7.1-fpm \
      php7.1-gd \
      php7.1-iconv \
      php7.1-intl \
      php7.1-json \
      php7.1-mbstring \
      php7.1-mcrypt \
      php7.1-mysql \
      php7.1-opcache \
      php7.1-pdo \
      php7.1-pgsql \
      php7.1-phar \
      php7.1-posix \
      php7.1-simplexml \
      php7.1-soap \
      php7.1-tidy \
      php7.1-tokenizer \
      php7.1-xml \
      php7.1-xmlwriter \
      php7.1-zip \
      supervisor \
      unzip \
      wget \
 && true

ENV ORO_VERSION=2.6.0 \
    INSTALLDIR=/srv/orocrm 

RUN set -u \
 && rm -f /etc/php/7.1/fpm/pool.d/www.conf \
 && ln -sT ${INSTALLDIR}/php-fpm.conf /etc/php/7.1/fpm/pool.d/orocrm.conf \
 && ln -sT ${INSTALLDIR}/php.ini      /etc/php/7.1/fpm/conf.d/orocrm.ini \
 && ln -sT ${INSTALLDIR}/php.ini      /etc/php/7.1/cli/conf.d/orocrm.ini \
 && ln -sT ${INSTALLDIR}/oro-console.sh /usr/local/bin/oro-console \
 && mkdir -p ${INSTALLDIR} \
 && chown -R www-data:www-data ${INSTALLDIR} \
 && su - www-data -s /bin/bash -c "git clone https://github.com/oroinc/crm-application.git ${INSTALLDIR}/src" \
 && su - www-data -s /bin/bash -c "git -C ${INSTALLDIR}/src/ checkout ${ORO_VERSION}" \
 && su - www-data -s /bin/bash -c "composer -d=${INSTALLDIR}/src install --prefer-dist --no-dev --no-interaction" \
 && true

ADD files/ ${INSTALLDIR}

ENTRYPOINT [ "/srv/orocrm/entrypoint.sh" ]
