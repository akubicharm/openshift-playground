FROM centos

MAINTAINER "Kei Omizo" <komizo@redhat.com>

ENV OC_VERSION "3.7.42"


ADD https://mirror.openshift.com/pub/openshift-v3/clients/$OC_VERSION/linux/oc.tar.gz /tmp/oc.tar.gz

RUN cd /usr/bin; tar xvf /tmp/oc.tar.gz 


ENV APP_ROOT=/opt/app-root
ENV HOME=${APP_ROOT}
RUN mkdir ${APP_ROOT}
RUN chmod -R u+x ${APP_ROOT} && \
    chgrp -R 0 ${APP_ROOT} && \
    chmod -R g=u ${APP_ROOT} /etc/passwd

USER 10001
WORKDIR ${APP_ROOT}

ENTRYPOINT ["sh", "-c", "/usr/bin/tail -f /dev/null"]
VOLUME ${APP_ROOT}/logs ${APP_ROOT}/data
CMD ["sh", "-c", "/usr/bin/tail -f /dev/null"]
