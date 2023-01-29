#!/bin/bash
sudo yum install -y nfs-utils
systemctl enable firewalld --now 
sudo firewall-cmd --add-port=2049/udp
sudo mkdir -p /mnt
sudo echo "192.168.50.10:/srv/share/ /mnt nfs vers=3,proto=udp,noauto,x-systemd.automount 0 0" >> /etc/fstab 
sudo systemctl daemon-reload 
sudo systemctl restart remote-fs.target 