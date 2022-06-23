ARG LC_ALL=en_US.utf8 LANG=en_US.utf8
ARG WORKDIR=/data/projects/fate

FROM centos:7

ARG LC_ALL LANG WORKDIR

WORKDIR $WORKDIR

# install java python npm
RUN set -eux; \
    rpm --rebuilddb; \
    rpm --import /etc/pki/rpm-gpg/RPM*; \
    yum upgrade -y; \
    yum install -y gcc-c++ make; \
    # install java \
    yum install -y java-1.8.0-openjdk java-1.8.0-openjdk-devel ; \
    # install python \
    yum install -y python3.6; \
    # install nodejs \
    curl -fsSL https://rpm.nodesource.com/setup_18.x | bash - ; \
    yum install -y  nodejs; \

    yum clean all;