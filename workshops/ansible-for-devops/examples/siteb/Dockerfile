FROM registry.access.redhat.com/rhscl/httpd-24-rhel7
USER root
MAINTAINER creynold@redhat.com
ADD ./etc/httpd/conf/httpd.conf /etc/httpd/conf
ADD ./var/www/html/index.html /var/www/html/
RUN chown -R apache:apache /var/www/html
EXPOSE 8080
