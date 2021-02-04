
FROM ubuntu

ENV TZ=America/Vancouver
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone
RUN DEBIAN_FRONTEND=noninteractive TZ=America/Vancouver apt-get update -y && apt-get install apache2 apache2-utils -y


RUN apt-get update
RUN apt-get install -y software-properties-common && \
add-apt-repository ppa:ondrej/php && apt-get update
RUN apt-get install -y curl


RUN  DEBIAN_FRONTEND=noninteractive TZ=America/Vancouver apt-get install -y  --allow-unauthenticated php5.6 php5.6-mysql php5.6-mcrypt php5.6-cli php5.6-gd php5.6-curl
RUN a2enmod php5.6
RUN a2enmod rewrite

ENV APACHE_LOG_DIR /var/log/apache2
ENV APACHE_LOCK_DIR /var/lock/apache2
ENV APACHE_PID_FILE /var/run/apache2.pid


ADD apache-config.conf /etc/apache2/sites-enabled/000-default.conf
ADD php.ini /etc/php/5.6/apache2/php.ini
RUN a2enmod cgi headers proxy proxy_ajp proxy_balancer proxy_connect proxy_html proxy_http proxy_wstunnel rewrite slotmem_shm socache_shmcb ssl

VOLUME ["/var/www/website"]

EXPOSE 80
#EXPOSE 8080
EXPOSE 443
#EXPOSE 3306

EXPOSE 80
ENTRYPOINT [ "/usr/sbin/apache2ctl" ]
CMD [ "-D", "FOREGROUND" ]
