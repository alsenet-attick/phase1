#!/bin/bash
#-----------------------------------------------------------------------------------------------------------#
#
#						USBrobot
#		License : CC BY-SA
#		Contribution: Patrice Rojas Alsenet Sa, Free It Foundation
#		
#-----------------------------------------------------------------------------------------------------------#


path=$(pwd)
image_name='Entraide_Numerique'
if [ "$EUID" -ne 0 ]
  then echo "Please run as root"
  exit 1
fi

#prep mysql: for debugging, otherwise mysql socket of host system will be used
check_mysql_running=$(netstat -lnt | awk '$6 == "LISTEN" && $4 ~ ".3306"')

# Check if variable has length greater than 0
if [ -n ${check_mysql_running} ]
   then echo "Your Mysql server is running! This can raise issues within chroot environnement. Please disable mysql before running this script."
   exit 1
fi


#check_apache=$(netstat -lnt| awk '$6 == "LISTEN" && $4 ~ ".80"')
# Check if variable has length greater than 0
#if [ -n "${check_apache}"  ] 
#   then echo "Your Apache server is running! This can raise issues within chroot environnement. Please disable mysql before running this script."
#   exit 1
#fi

#Checks if file exists and is not empty
if [ -s ./ubuntu-14.04-desktop-amd64.iso ];
    then echo "ubuntu iso already exists" 
else 
    wget http://releases.ubuntu.com/14.04/ubuntu-14.04-desktop-amd64.iso -O ubuntu-14.04-desktop-amd64.iso 
    wget http://releases.ubuntu.com/trusty/MD5SUMS
    sumcheck={$md5sum -c <(grep ubuntu-14.04-desktop-amd64.iso MD5SUMS)}
    if [ -n "$sumcheck" ]
        then echo "Exited because MD5 checksum isn't correct!"
	exit 1
    fi
fi

#DEPENDENCIES
apt-get install syslinux squashfs-tools genisoimage

#Mount & Extract iso
mkdir -p mnt extract-cd edit

modprobe loop
mount -o loop,ro ubuntu-14.04-desktop-amd64.iso mnt
rsync -a mnt/ extract-cd --exclude=casper/filesystem.squashfs
chmod -R 755  extract-cd edit

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
chroot edit dpkg-query -W --showformat='${Package} ${Version}\n' > filesystem.manifest
mv edit/filesystem.manifest extract-cd/casper/filesystem.manifest

sudo cp extract-cd/casper/filesystem.manifest extract-cd/casper/filesystem.manifest-desktop
sed -i '/ubiquity/d' extract-cd/casper/filesystem.manifest-desktop
sed -i '/casper/d' extract-cd/casper/filesystem.manifest-desktop


# Best compression allowed
sudo rm extract-cd/casper/filesystem.squashfs
mksquashfs edit extract-cd/casper/filesystem.squashfs -comp xz

printf $(sudo du -sx --block-size=1 edit | cut -f1) > extract-cd/casper/filesystem.size

#Name of the image
echo entraide_numerique>> extract-cd/README.diskdefines

# MD5 sum
cd $path/extract-cd
rm md5sum.txt
find -type f -print0 | xargs -0 md5sum | grep -v isolinux/boot.cat | tee md5sum.txt

#Must execute in extract-cd file!
sudo mkisofs --joliet-long -D -r -V "$image_name" -cache-inodes -J -l -b isolinux/isolinux.bin -c isolinux/boot.cat -no-emul-boot -boot-load-size 4 -boot-info-table -o ../ubuntu-14.04-desktop-remix.iso .
sudo chown $USER ubuntu-14.04-desktop-remix.iso

cd $path

exit

touch $path/edit/clean.sh
cat "apt-get clean; umount proc sys /dev/pts; exit">$path/edit/clean.sh
chroot edit clean.sh
rm -rf $path/edit/clean.sh

umount edit/dev
umount mnt
rm -rf mnt edit squashfs-root 

