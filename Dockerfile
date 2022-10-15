FROM centos
ENV container docker
RUN sed -i 's/mirrorlist/#mirrorlist/g' /etc/yum.repos.d/CentOS-*
RUN sed -i 's|#baseurl=http://mirror.centos.org|baseurl=http://vault.centos.org|g' /etc/yum.repos.d/CentOS-*
RUN yum -y update ; yum clean all
RUN yum -y install systemd 
RUN (cd /lib/systemd/system/sysinit.target.wants/; for i in *; do [ $i == \
    systemd-tmpfiles-setup.service ] || rm -f $i; done); \
    rm -f /lib/systemd/system/multi-user.target.wants/*;\
    rm -f /etc/systemd/system/*.wants/*;\
    rm -f /lib/systemd/system/local-fs.target.wants/*; \
    rm -f /lib/systemd/system/sockets.target.wants/*udev*; \
    rm -f /lib/systemd/system/sockets.target.wants/*initctl*; \
    rm -f /lib/systemd/system/basic.target.wants/*;\
    rm -f /lib/systemd/system/anaconda.target.wants/*;
    VOLUME [ "/sys/fs/cgroup" ]
    CMD ["/usr/sbin/init"]
ADD gcsfuse.repo /etc/yum.repos.d/gcsfuse.repo
RUN yum -y install gcsfuse samba-common-tools realmd oddjob oddjob-mkhomedir sssd adcli krb5-workstation nscd
RUN mkdir -p /export
RUN mkdir -p /opt/smbcust
COPY dockerentry.sh /opt/smbcust/
RUN chmod +rx /opt/smbcust/dockerentry.sh

VOLUME ["/export"]
EXPOSE 139
EXPOSE 445
ENTRYPOINT ["/opt/smbcust/dockerentry.sh"]
