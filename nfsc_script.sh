#!/bin/bash
yum install -y nfs-utils
systemctl enable firewalld --now 
mkdir -p /mnt
echo "192.168.50.10:/srv/share/ /mnt nfs vers=3,proto=udp,noauto,x-systemd.automount 0 0" >> /etc/fstab 
systemctl daemon-reload 
systemctl restart remote-fs.target 
