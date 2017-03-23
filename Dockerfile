FROM resin/rpi-raspbian:jessie-20160831

MAINTAINER Oleg Yunin <oayunin@gmail.com>

RUN apt-get update && apt-get upgrade
RUN apt-get install -y \
	git \
    vim \
    curl \
    wget

# hfs+ support
RUN apt-get install -y \
	hfsprogs \
	hfsplus

# install docker
RUN sed -i 's/wheezy/jessie/' /etc/apt/sources.list
RUN sed -i 's/wheezy/jessie/' /etc/apt/sources.list.d/raspi.list 
RUN apt-get update && sudo apt-get -y upgrade # answer 'y' to upcoming questions 
RUN apt-get -y dist-upgrade # answer 'y' to upcoming questions
RUN apt-get -y autoremove
RUN apt-get -y purge $(dpkg -l | awk '/^rc/ { print $2 }')

RUN curl -s https://packagecloud.io/install/repositories/Hypriot/Schatzkiste/script.deb.sh | sudo bash
RUN apt-get install -y docker-hypriot=1.10.3-1
RUN systemctl enable docker.service

# prepare for netatalk
RUN apt-get install -y \
    avahi-daemon \
    build-essential \
    libacl1-dev \
    libavahi-client-dev \
    libcrack2-dev \
    libdb-dev \
    libdbus-1-dev \
    libdbus-glib-1-dev \
    libevent-dev \
    libgcrypt11-dev \
    libglib2.0-dev \
    libio-socket-inet6-perl \
    libkrb5-dev \
    libldap2-dev \
    libmysqlclient-dev \
    libpam0g-dev \
    libssl-dev \
    libtdb-dev \
    libtracker-miner-1.0-dev \
    libtracker-sparql-1.0-dev \
    libwrap0-dev \
    systemtap-sdt-dev \
    tracker


RUN mkdir /build

WORKDIR /build
RUN wget http://prdownloads.sourceforge.net/netatalk/netatalk-3.1.10.tar.gz && tar -xf netatalk-3.1.10.tar.gz

WORKDIR /build/netatalk-3.1.10
RUN ./configure \
        --with-init-style=debian-systemd \
        --without-libevent \
        --without-tdb \
        --with-cracklib \
        --enable-krbV-uam \
        --with-pam-confdir=/etc/pam.d \
        --with-dbus-daemon=/usr/bin/dbus-daemon \
        --with-dbus-sysconf-dir=/etc/dbus-1/system.d \
        --with-tracker-pkgconfig-version=1.0

RUN make
RUN make install

# setup netatalk
RUN cat /etc/nsswitch.conf | grep -v "hosts:          files dns" > /tmp/nsswitch.conf \
    && echo "hosts: files mdns4_minimal [NOTFOUND=return] dns mdns4 mdns" >> /tmp/nsswitch.conf \
    && mv /tmp/nsswitch.conf /etc/nsswitch.conf

RUN echo "\
<?xml version="1.0" standalone='no'?><!--*-nxml-*--> \n\
<!DOCTYPE service-group SYSTEM "avahi-service.dtd"> \n\
<service-group> \n\
    <name replace-wildcards="yes">%h</name> \n\
    <service> \n\
        <type>_afpovertcp._tcp</type> \n\
        <port>548</port> \n\
    </service> \n\
    <service> \n\
        <type>_device-info._tcp</type> \n\
        <port>0</port> \n\
        <txt-record>model=TimeCapsule</txt-record> \n\
    </service> \n\
</service-group>" > /etc/avahi/services/afpd.service

RUN echo "\n\
  mimic model = TimeCapsule6,106\n\
\n\
[Time Machine]\n\
  path = /media/tm\n\
  time machine = yes" >> /usr/local/etc/afp.conf 

#RUN service avahi-daemon start && service netatalk start
#RUN systemctl enable avahi-daemon && systemctl enable netatalk

WORKDIR /

CMD while true; sleep 100000; done
