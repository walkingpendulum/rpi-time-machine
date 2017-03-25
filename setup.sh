#
# sources:
# https://thatvirtualboy.com/2016/11/03/send-time-machine-backups-to-a-vm-hosted-in-windows/
# https://www.howtogeek.com/276468/how-to-use-a-raspberry-pi-as-a-networked-time-machine-drive-for-your-mac/
#

sudo apt-get update 
sudo apt-get upgrade -y
sudo apt-get install -y \
	git \
    vim \
    curl \
    wget

# hfs+ support
sudo apt-get install -y \
	hfsprogs \
	hfsplus

# prepare for netatalk
sudo apt-get install -y \
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


mkdir /build
cd /build
wget http://prdownloads.sourceforge.net/netatalk/netatalk-3.1.10.tar.gz && tar -xf netatalk-3.1.10.tar.gz

cd /build/netatalk-3.1.10
sudo ./configure \
        --with-init-style=debian-systemd \
        --without-libevent \
        --without-tdb \
        --with-cracklib \
        --enable-krbV-uam \
        --with-pam-confdir=/etc/pam.d \
        --with-dbus-daemon=/usr/bin/dbus-daemon \
        --with-dbus-sysconf-dir=/etc/dbus-1/system.d \
        --with-tracker-pkgconfig-version=1.0

sudo make
sudo make install

# setup netatalk
cat /etc/nsswitch.conf | grep -v "hosts:          files dns" > /tmp/nsswitch.conf \
    && echo "hosts: files mdns4_minimal [NOTFOUND=return] dns mdns4 mdns" >> /tmp/nsswitch.conf \
    && sudo mv /tmp/nsswitch.conf /etc/nsswitch.conf

sudo cp afpd.service /etc/avahi/services/afpd.service
sudo cp afp.conf /usr/local/etc/afp.conf 

sudo /etc/init.d/avahi-daemon start
sudo service netatalk start

sudo update-rc.d avahi-daemon defaults
sudo systemctl enable netatalk

echo "DONE"
