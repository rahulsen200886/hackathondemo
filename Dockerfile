FROM centos
ENV container docker
RUN sed -i 's/mirrorlist/#mirrorlist/g' /etc/yum.repos.d/CentOS-*
RUN sed -i 's|#baseurl=http://mirror.centos.org|baseurl=http://vault.centos.org|g' /etc/yum.repos.d/CentOS-*
RUN (cd /lib/systemd/system/sysinit.target.wants/; for i in *; do [ $i == \
    systemd-tmpfiles-setup.service ] || rm -f $i; done); \
    rm -f /lib/systemd/system/multi-user.target.wants/*;\
    rm -f /etc/systemd/system/*.wants/*;\
    rm -f /lib/systemd/system/local-fs.target.wants/*; \
    rm -f /lib/systemd/system/sockets.target.wants/*udev*; \
    rm -f /lib/systemd/system/sockets.target.wants/*initctl*; \
    rm -f /lib/systemd/system/basic.target.wants/*;\
    rm -f /lib/systemd/system/anaconda.target.wants/*; 

ADD gcsfuse.repo /etc/yum.repos.d/gcsfuse.repo
RUN mkdir -p /export
RUN mkdir -p /opt/smbcust
RUN useradd -m mysmbuser -p changemelater
RUN groupadd smbgroup
RUN usermod -a -G smbgroup mysmbuser
RUN mkdir -p /export
RUN chmod 755 /export
COPY dockerentry.sh /opt/smbcust/
RUN chmod +rx /opt/smbcust/dockerentry.sh
RUN yum -y update 
RUN yum -y install gcsfuse samba samba-common-tools realmd oddjob oddjob-mkhomedir sssd adcli krb5-workstation nscd

VOLUME ["/export"]
EXPOSE 139
EXPOSE 445
ENTRYPOINT  ["bash","/opt/smbcust/dockerentry.sh"]
CMD ["/usr/sbin/init"]
CMD ["/export"]
