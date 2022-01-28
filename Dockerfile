FROM centos:7
MAINTAINER madebymode

RUN rpm -Uvh https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
RUN rpm -Uvh https://repo.ius.io/ius-release-el7.rpm
#php72u is archived
RUN yum-config-manager --enable ius-archive

# Update and install latest packages and prerequisites
RUN yum update -y \
    && yum install -y --nogpgcheck --setopt=tsflags=nodocs \
        php72u-cli \
        php72u-common \
        php72u-fpm \
        php72u-gd \
        php72u-mbstring \
        php72u-mysqlnd \
        php72u-xml \
        php72u-json \
        php72u-intl \
    && yum clean all && yum history new

RUN sed -e 's/127.0.0.1:9000/9000/' \
        -e '/allowed_clients/d' \
        -e '/catch_workers_output/s/^;//' \
        -e '/error_log/d' \
        -i /etc/php-fpm.d/www.conf
        
#composer 1.10
RUN curl -sS https://getcomposer.org/installer | php -- --version=1.10.22 --install-dir=/usr/local/bin --filename=composer
#composer 2
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer2
        

# this update breaks fpm on docker, so we comment it out: https://github.com/iusrepo/php72u/issues/17
RUN sed -e '/^pid/s//;pid/' -i /etc/php-fpm.conf

CMD ["php-fpm", "-F"]

EXPOSE 9000
