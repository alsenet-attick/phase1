
apt-get -y clean

umount proc /proc
umount sysfs /sys
umount devpts /dev/pts

#rm -rf /tmp/*
#rm /etc/resolv.conf

exit
