#!/bin/bash


mount none -t proc /proc
mount none -t sysfs /sys
mount none -t devpts /dev/pts


export HOME=/root
locale-gen fr_CH.UTF-8
export LC_ALL=fr_CH.UTF-8


dpkg-divert --local --rename --add /sbin/initctl
apt-get -y install debconf-utils
apt-get -y update
apt-get install -y apache2

# later add random key generator
MYSQL_PASSWORD=1234
debconf-set-selections <<< 'mysql-server mysql-server/root_password password 1234'
debconf-set-selections <<< 'mysql-server mysql-server/root_password_again password 1234'

apt-get install -y --force-yes mysql-server
apt-get install -y php5-mysql php5 libapache2-mod-php5 

#no apt-repo for php5-mcrypt

# path to modif backgrounds: /usr/share/backgrounds
# gconf file for gnome customization with : gconf-tool-2

# Mysql Config ... a modifier -> hash? token based?!

mysql -u root -p 1234 --execute=createdatabase wikidb
mysql -u root -p 1234 --execute=createdatabase etherpad

addgroup services
# Wikimedia
#adduser -u 11 wiki -g services
apt-get -y install git
git clone https://gerrit.wikimedia.org/r/p/mediawiki/core.git /home/wiki/w
cp -r w /var/www/html/

# Nodejs dep + etherpad
adduser -u 23 padder -g services
 su padder
  apt-get install -y gzip git curl python libssl-dev pkg-config build-essential
  apt-get -y update
  apt-get install -y nodejs npm
  git clone git://github.com/ether/etherpad-lite.git etherpad
  chmod a+x etherpad/
 exit

# studs
wget https://sourcesup.cru.fr/frs/download.php/3173/studs_0.6.5.tar.gz -O studs.tar.gz
tar -xvf studs.tar.gz
rm -rf studs.tar.gz
mv studs /var/www/html

# wisemap
#adduser wisemap -g services
git clone https://bitbucket.org/wisemapping/wisemapping-open-source.git /var/www/html/wisemap

#touch passwords.txt
#echo $hash >> passwords.txt

apt-get -y clean

umount proc /proc
umount sysfs /sys
umount devpts /dev/pts

#rm -rf /tmp/*
#rm /etc/resolv.conf

exit

