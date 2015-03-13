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
apt-get install -y screen

# later add random key generator
MYSQL_PASSWORD=1234
#debconf-set-selections <<< 'mysql-server mysql-server/root_password password 1234'
#debconf-set-selections <<< 'mysql-server mysql-server/root_password_again password 1234'

apt-get install -y software-properties-common
apt-key adv --recv-keys --keyserver hkp://keyserver.ubuntu.com:80 0xcbcb082a1bb943db
add-apt-repository -y 'deb http://mariadb.mirror.nucleus.be//repo/10.0/ubuntu trusty main'
apt-get -y update
DEBIAN_FRONTEND=noninteractive apt-get -y install mariadb-server
mysqladmin -u root password $MYSQL_PASSWORD
apt-get install -y php5-mysql php5 libapache2-mod-php5 

#no apt-repo for php5-mcrypt

# path to modif backgrounds: /usr/share/backgrounds
# gconf file for gnome customization with : gconf-tool-2

# Mariadb Config ... a modifier -> hash? token based?!

mysql -u root -p 1234 --execute=createdatabase wikidb
mysql -u root -p 1234 --execute=createdatabase etherpad

addgroup services
# Wikimedia
adduser -u 11 wiki -g services
apt-get -y install git
git clone https://gerrit.wikimedia.org/r/p/mediawiki/core.git /home/wiki/w
cp -r w /var/www/html/

# Nodejs dep + etherpad
adduser -u 23 padder -g services
 su padder
  apt-get install -y gzip git curl python libssl-dev pkg-config build-essential
  apt-get -y update
  apt-get install -y python-software-properties
  apt-add-repositories -y ppa:chris-lea/node.js
  apt-get update -y
  apt-get install -y nodejs npm # from joyent github

  git clone git://github.com/ether/etherpad-lite.git etherpad
  chmod a+x etherpad/
  sed '$iscreen -t etherpad node run.js' /etc/rc.local
 exit

# studs
wget https://sourcesup.cru.fr/frs/download.php/3173/studs_0.6.5.tar.gz -O studs.tar.gz
tar -xvf studs.tar.gz
rm -rf studs.tar.gz
mv studs /var/www/html

# wisemap
adduser wisemapping -g services
git clone https://bitbucket.org/wisemapping/wisemapping-open-source.git /var/www/html/wisemapping
chown wisemapping:services -R /var/www/html/wisemapping
cd /var/www/html/wisemapping
mysql -uroot -p1234 < create-database.sql
mysql -uroot -Dwisemapping -p1234 < create-schemas.sql
As a Service:
touch /etc/init.d/wisemapping
cat cd /var/www/wisemapping && java -Xmx256m -Dorg.apache.jasper.compiler.disablejsr199=true -jar start.jar >/etc/init.d/wisemapping

#touch passwords.txt
#echo $hash >> passwords.txt
cd

# ethercalc
apt-add-repository ppa:chris-lea/redis-server
apt-get install redis-server
git clone https://github.com/audreyt/ethercalc.git ethercalc
apt-get update
adduser -u 26 etherclac -g services
npm install -g ethercalc

exit

