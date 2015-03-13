# phase1
phase1 du projet Entraide Numérique

== USB bootable ==

Liste des applications:<br>
* installation et automatisation de mariadb et apache2
* creation des bases de données nécessaires aux services 
* acces direct depuis le browser aux services:
 studs: http://localhost/studs
 mediawiki: http://localhost/w
 wisemapping: http://localhost/wisemap
 Etherpad: http://localhost:9001
 Sinon Etherpad accessible en ligne de commande:
 $ nodejs etherpad


Liste des modifications:
* MariaDB install automation
* param to enable connection while chroot: modif resolv.conf, hosts, apt-list
* Splash screen modification and wallpapers (logos and design of entraide numérique)
* installation des applications framas et d'un wiki
* param mariaDB et apache pour starter au début de l'installation


RoadMap:
* Individual Key generation for each services passwords usb.
* To test: Screen executing instance of etherpad on boot
* Ethercalc issues
* Diaspora ?

