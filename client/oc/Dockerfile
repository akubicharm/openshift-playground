FROM registry.access.redhat.com/rhel7/rhel:latest

MAINTAINER Kei Omizo <komizo@redhat.com>

ENV OC_VERSION=v1.3.0 \
    OC_TAG_SHA=3ab7af3d097b57f933eccef684a714f2368804e7 \
    BUILD_DEPS='curl tar gzip' \
    RUN_DEPS='ca-certificates gettext'

RUN curl -sLo  /tmp/oc.tar.gz https://github.com/openshift/origin/releases/download/v1.3.0/openshift-origin-client-tools-v1.3.0-3ab7af3d097b57f933eccef684a714f2368804e7-linux-64bit.tar.gz &&\
    tar xvf /tmp/oc.tar.gz -C /tmp/ &&\
    mv /tmp/openshift-origin-client-tools-${OC_VERSION}-${OC_TAG_SHA}-linux-64bit/oc /usr/local/bin/ && \
    rm -fr /tmp/oc.tar.gz 

CMD ["/bin/sh"]
