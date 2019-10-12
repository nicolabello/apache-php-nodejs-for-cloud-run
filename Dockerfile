# https://engineering.bitnami.com/articles/minideb-a-new-container-base-image.html
# https://hub.docker.com/r/bitnami/minideb
# https://github.com/bitnami/minideb
FROM bitnami/minideb:latest

#
# Apache
#

# Install
RUN install_packages apache2 libapache2-mod-security2 libapache2-mod-evasive

# Add configs
COPY ./apache/ /etc/apache2/

# Enable configs
RUN a2enconf x-base x-logs x-security

# Enable modules
RUN a2enmod rewrite deflate expires headers &&\
    a2enmod info status &&\
    a2enmod evasive

# Forward logs to docker
RUN ln -sf /dev/stdout /var/log/apache2/access.log &&\
    ln -sf /dev/stdout /var/log/apache2/other_vhosts_access.log &&\
    ln -sf /dev/stderr /var/log/apache2/error.log

#
# Apache ModSecurity
# https://www.linode.com/docs/web-servers/apache-tips-and-tricks/configure-modsecurity-on-apache/
#

# Enable modules
RUN a2enmod unique_id security2

# Enable config
RUN mv /etc/modsecurity/modsecurity.conf-recommended /etc/modsecurity/modsecurity.conf

# Set logging format
RUN sed -i '/SecAuditLogParts/c\SecAuditLogParts AHZ' /etc/modsecurity/modsecurity.conf

# OWASP ModSecurity Core Rule Set
ENV MODSECURITY_CRS_VERSION 3.1.1

# Download and extract
ADD https://github.com/SpiderLabs/owasp-modsecurity-crs/archive/v${MODSECURITY_CRS_VERSION}.tar.gz /tmp/modsecurity-crs.tar.gz
RUN tar -xf /tmp/modsecurity-crs.tar.gz -C /tmp/ && mv /tmp/owasp-modsecurity-crs-${MODSECURITY_CRS_VERSION} /etc/modsecurity-crs

# Enable config
RUN mv /etc/modsecurity-crs/crs-setup.conf.example /etc/modsecurity-crs/crs-setup.conf

# Forward logs to docker
RUN ln -sf /dev/stdout /var/log/apache2/modsec_audit.log

#
# PHP
#

ENV PHP_VERSION 7.3

# Install
RUN install_packages libapache2-mod-php${PHP_VERSION} php${PHP_VERSION} php${PHP_VERSION}-common php${PHP_VERSION}-fpm php-pear

# Enable modules
RUN a2enmod php${PHP_VERSION}

# Add phpinfo
RUN echo "<?php phpinfo(); ?>" > /var/www/html/phpinfo.php && a2enconf x-phpinfo

# Set error log file
RUN sed -i '/error_log = php_errors.log/c\error_log = /var/log/php_errors.log' /etc/php/${PHP_VERSION}/apache2/php.ini

# Forward logs to docker
RUN ln -sf /dev/stderr /var/log/php_errors.log

#
# PHP-FPM
# http://www.etcwiki.org/wiki/Setup_php-fpm_7_with_Apache_on_Debian_9_Stretch
# https://cwiki.apache.org/confluence/display/httpd/PHP-FPM
#

# Enable modules (As pointed out during installation)
RUN a2enmod proxy_fcgi setenvif

# Enable config (As pointed out during installation)
RUN a2enconf php${PHP_VERSION}-fpm

# Set error log file
RUN sed -i '/error_log = php_errors.log/c\error_log = /var/log/php_errors.log' /etc/php/${PHP_VERSION}/fpm/php.ini

# Change listen address
RUN sed -i '/listen = /c\listen = 127.0.0.1:9000' /etc/php/${PHP_VERSION}/fpm/pool.d/www.conf

# Preserve environment variables
# RUN sed -i '/clear_env = /c\clear_env = no' /etc/php/${PHP_VERSION}/fpm/pool.d/www.conf

# Forward logs to docker
RUN ln -sf /dev/stderr /var/log/php${PHP_VERSION}-fpm.log

#
# Node
# https://github.com/nodejs/help/wiki/Installation
#

ENV NODEJS_VERSION 12.10.0

# Download and extract
ADD https://nodejs.org/dist/v${NODEJS_VERSION}/node-v${NODEJS_VERSION}-linux-x64.tar.gz /tmp/nodejs.tar.gz
RUN tar -xf /tmp/nodejs.tar.gz -C /tmp/ && mv /tmp/node-v${NODEJS_VERSION}-linux-x64 /usr/lib/nodejs

# Add to path
RUN ln -sf /usr/lib/nodejs/bin/* /usr/bin/

#
# Yarn
# https://yarnpkg.com/lang/en/docs/install/#debian-stable
#

# Download and extract
ADD https://yarnpkg.com/latest.tar.gz /tmp/yarn.tar.gz
RUN tar -xf /tmp/yarn.tar.gz -C /tmp/ && mv "/tmp/`ls /tmp | egrep 'yarn-v.*' | head -1`" /usr/lib/yarn

# Add to path
RUN ln -sf /usr/lib/yarn/bin/* /usr/bin/

#
# Optimizations
#

# Disable PHP (PHP-FPM will be used instead)
RUN a2dismod php${PHP_VERSION}

# Use MPM Worker
RUN a2dismod mpm_prefork && a2enmod mpm_event

# Disable CustomLog
RUN a2disconf other-vhosts-access-log

#
# Misc
#

# Cleanup
RUN rm -rf /tmp/*

# Create folder's symbolic links
RUN ln -sf /var/www /apps
RUN ln -sf /etc/apache2/sites-enabled /vhosts

# Default port
EXPOSE 8080

# Add entrypoint
COPY ./entrypoint.sh /
RUN chmod +x /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
