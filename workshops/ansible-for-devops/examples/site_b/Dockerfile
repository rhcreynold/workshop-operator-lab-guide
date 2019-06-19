# Pull the rhel image from the local registry
FROM rhscl/httpd-24-rhel7
USER root

MAINTAINER student1

# Add configuration file
ADD httpd.conf /etc/httpd/conf
ADD index.html /var/www/html/
RUN chown -R apache:apache /var/www/html
EXPOSE 80
