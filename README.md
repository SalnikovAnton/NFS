# NFS, FUSE_Vagrant стенд для NFS
1) vagrant up должен поднимать 2 настроенных виртуальных машины (сервер NFS и клиента) без дополнительных ручных действий; - на сервере NFS должна быть подготовлена и экспортирована директория; 
2) в экспортированной директории должна быть поддиректория с именем __upload__ с правами на запись в неё; \
3) экспортированная директория должна автоматически монтироваться на клиенте при старте виртуальной машины (systemd, autofs или fstab -  любым способом);
4) монтирование и работа NFS на клиенте должна быть организована с использованием NFSv3 по протоколу UDP; 
5) firewall должен быть включен и настроен как на клиенте, так и на сервере. 

#### 1 Готовим Vagrantfile на развертывание двух машин с centos/7 и с подключенными скриптами дополнительной настройки для каждой машины nfsы_script.sh и nfsc_script.sh .

#### 2 В скрипте для сервера прописываем создание директории и присваиваем права доступа. 
```
mkdir -p /srv/share/upload 
chown -R nfsnobody:nfsnobody /srv/share 
chmod 0777 /srv/share/upload
cat << EOF > /etc/exports 
/srv/share 192.168.50.11/24(rw,sync,root_squash) 
EOF
```
 
 #### 3 В скрипте для клиента прописываем автоматическое монтирование директории при старте машины
```
mkdir -p /mnt
echo "192.168.50.10:/srv/share/ /mnt nfs vers=3,proto=udp,noauto,x-systemd.automount 0 0" >> /etc/fstab 
systemctl daemon-reload 
systemctl restart remote-fs.target
```
 
 #### 4 монтирование и работа NFS на клиенте организована с использованием NFSv3 по протоколу UDP
```
echo "192.168.50.10:/srv/share/ /mnt nfs vers=3,proto=udp,noauto,x-systemd.automount 0 0" >> /etc/fstab 
```
 
 #### 5 Включение firewall на сервере прописываем командой с добавлением сервисов и проверяем статус после подключения по ssh
``` 
systemctl enable firewalld --now
firewall-cmd --add-service=nfs3 --add-service=rpc-bind --add-service=mountd --permanent
firewall-cmd --reload
``` 

``` 
[root@nfss ~]# systemctl status firewalld
● firewalld.service - firewalld - dynamic firewall daemon
   Loaded: loaded (/usr/lib/systemd/system/firewalld.service; enabled; vendor preset: enabled)
   Active: active (running) since Sun 2023-01-29 15:19:41 UTC; 27min ago
     Docs: man:firewalld(1)
 Main PID: 3388 (firewalld)
   CGroup: /system.slice/firewalld.service
           └─3388 /usr/bin/python2 -Es /usr/sbin/firewalld --nofork --nopid

Jan 29 15:19:40 nfss systemd[1]: Starting firewalld - dynamic firewall daemon...
Jan 29 15:19:41 nfss systemd[1]: Started firewalld - dynamic firewall daemon.
Jan 29 15:19:42 nfss firewalld[3388]: WARNING: AllowZoneDrifting is enabled. This is considered an insecure configuration ...it now.
Jan 29 15:19:44 nfss firewalld[3388]: WARNING: AllowZoneDrifting is enabled. This is considered an insecure configuration ...it now.
Hint: Some lines were ellipsized, use -l to show in full.
```
 
 Включение firewall на клиенте прописываем командой и проверяем статус после подключения по ssh
``` 
systemctl enable firewalld --now 
``` 

``` 
[root@nfsc ~]# systemctl status firewalld       
● firewalld.service - firewalld - dynamic firewall daemon
   Loaded: loaded (/usr/lib/systemd/system/firewalld.service; enabled; vendor preset: enabled)
   Active: active (running) since Sun 2023-01-29 15:22:32 UTC; 27min ago
     Docs: man:firewalld(1)
 Main PID: 3395 (firewalld)
   CGroup: /system.slice/firewalld.service
           └─3395 /usr/bin/python2 -Es /usr/sbin/firewalld --nofork --nopid

Jan 29 15:22:30 nfsc systemd[1]: Starting firewalld - dynamic firewall daemon...
Jan 29 15:22:32 nfsc systemd[1]: Started firewalld - dynamic firewall daemon.
Jan 29 15:22:35 nfsc firewalld[3395]: WARNING: AllowZoneDrifting is enabled. This is considered an insecure configuration ...it now.
Hint: Some lines were ellipsized, use -l to show in full.
```
 
 
 
