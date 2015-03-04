#!/bin/bash
#-----------------------------------------------------------------------------------------------------------#
#
#						USBrobot
#		License : CC-by-SA
#		Contribution: Patrice Rojas Alsenet Sa, FreeIt Foundation
#		
#-----------------------------------------------------------------------------------------------------------#
IMAGE_NAME = 'Entraide'
if [ "$EUID" -ne 0 ]
  then echo "Please run as root"
  exit
fi

if [ -e ./ubuntu-14.04-desktop-amd64.iso ]; 
 then echo "ubuntu iso already exists" 
 else wget http://releases.ubuntu.com/14.04/ubuntu-14.04-desktop-amd64.iso -O ubuntu-14.04-desktop-amd64.iso 
fi

#DEPENDENCIES
apt-get install syslinux squashfs-tools genisoimage

#prep mysql: to debug else it will use the host system
service mysql stop
apt-get remove mysql-server
killall mysqld


#Mount & Extract iso
mkdir -p mnt extract-cd edit

mount -o loop ubuntu-14.04-desktop-amd64.iso mnt
rsync -a mnt/ extract-cd --exclude=casper/filesystem.squashfs
chmod -R 755 mnt extract-cd edit

#Extract the SquashFS filesystem 
unsquashfs mnt/casper/filesystem.squashfs

mv squashfs-root/* edit/
cp edit.sh edit
chmod -R 755 edit 

#cp /etc/resolv.conf edit/etc/
#cp /etc/apt/sources.list edit/etc/apt/sources.list

cp /etc/hosts edit/etc
# OpenDNS server
echo 'nameserver 208.67.222.123' | sudo tee -a edit/etc/resolv.conf
# When design for entraide numerique, can create own resolv.conf hosts in edit/etc/
mount --bind /dev/ edit/dev
echo 'base system ready for operations!'

#Prepare and chroot

chroot edit /edit.sh
# Exec of edit.sh code
cd $path

chmod +w extract-cd/casper/filesystem.manifest

# Prepare ISO file
chroot edit dpkg-query -W --showformat='${Package} ${Version}\n' > extract-cd/casper/filesystem.manifest
sudo cp extract-cd/casper/filesystem.manifest extract-cd/casper/filesystem.manifest-desktop
sed -i '/ubiquity/d' extract-cd/casper/filesystem.manifest-desktop
sed -i '/casper/d' extract-cd/casper/filesystem.manifest-desktop

rm extract-cd/casper/filesystem.squashfs
# Best compression allowed
mksquashfs edit extract-cd/casper/filesystem.squashfs -xz
printf $(sudo du -sx --block-size=1 edit | cut -f1) > extract-cd/casper/filesystem.size

#Name of the image
echo entraide>> extract-cd/README.diskdefines

# MD5 sum
cd $path/extract-cd
rm md5sum.txt
find -type f -print0 | xargs -0 md5sum | grep -v isolinux/boot.cat | tee md5sum.txt


sudo mkisofs -D -r -V "$IMAGE_NAME" -cache-inodes -J -l -b isolinux/isolinux.bin -c isolinux/boot.cat -no-emul-boot -boot-load-size 4 -boot-info-table -o ../ubuntu-14.04-desktop-remix.iso .
chown $USER ubuntu-14.04-desktop-remix.iso
umount edit/dev
umount mnt

#restore mysql
apt-get install mysql-server

