FROM registry.access.redhat.com/rhscl/nginx-16-rhel7:latest

MAINTAINER NGINX Kei Omizo <komizo@redhat.com>

ENV NGINX_VERSION 1.6

# forward request and error logs to docker log collector
# RUN ln -sf /dev/stdout /var/log/nginx/access.log
# RUN ln -sf /dev/stderr /var/log/nginx/error.log

RUN chmod 777 /opt/rh/nginx16/root/etc/nginx

# VOLUME ["/var/cache/nginx"]

EXPOSE 8080 8443

USER 1001

CMD ["nginx", "-g", "daemon off;"]

