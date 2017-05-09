FROM registry.access.redhat.com/rhscl/nginx-110-rhel7:latest

MAINTAINER NGINX Kei Omizo <komizo@redhat.com>

ENV NGINX_VERSION 1.6

# forward request and error logs to docker log collector
# RUN ln -sf /dev/stdout /var/log/nginx/access.log
# RUN ln -sf /dev/stderr /var/log/nginx/error.log

RUN chown -R 1001:root /opt/rh/nginx110/root
RUN cat /usr/local/etc/nginx/nginx.conf | sed -e's/8080/80/g' > /usr/local/etc/nginx/nginx.conf

# VOLUME ["/var/cache/nginx"]

EXPOSE 8080 8443

USER 1001

CMD ["nginx", "-g", "daemon off;"]

