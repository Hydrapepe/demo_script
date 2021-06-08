#!/bin/bash
hostnamectl set-hostname R-RTR
mkdir repos
mv /etc/yum.repos.d/CentOS-* ./repos/
cp ./repos/CentOS-Media.repo /etc/yum.repos.d/
echo "[c7-media]" > /etc/yum.repos.d/CentOS-Media.repo
echo "name=CentOS-7 - Media" >> /etc/yum.repos.d/CentOS-Media.repo
echo "baseurl=file:///media/CentOS/" >> /etc/yum.repos.d/CentOS-Media.repo
echo "        file:///media/cdrom/" >> /etc/yum.repos.d/CentOS-Media.repo
echo "        file:///media/cdrecorder/" >> /etc/yum.repos.d/CentOS-Media.repo
echo "gpgcheck=1" >> /etc/yum.repos.d/CentOS-Media.repo
echo "enabled=1" >> /etc/yum.repos.d/CentOS-Media.repo
echo "gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-7" >> /etc/yum.repos.d/CentOS-Media.repo
mkdir /media/cdrom
mkdir /media/CentOS
mount /dev/sr0 /media/cdrom
mount /dev/sr1 /media/CentOS
yum -y install tcpdump net-tools curl vim lynx dhclient bind-utils nfs-utils cifs-utils nano bash-completion mc
echo -e "\n172.16.20.10    l-srv   l-srv.skill39.wsr" >> /etc/hosts
echo "10.10.10.1      l-fw    l-fw.skill39.wsr" >> /etc/hosts
echo "172.16.50.2     l-rtr-a l-rtr-a.skill39.wsr" >> /etc/hosts
echo "172.16.55.2     l-rtr-b l-rtr-b.skill39.wsr" >> /etc/hosts
echo "172.16.200.61   l-cli-b l-cli-b.skill39.wsr" >> /etc/hosts
echo "20.20.20.5      out-cli out-cli.skill39.wsr" >> /etc/hosts
echo "20.20.20.100    r-fw    r-fw.skill39.wsr" >> /etc/hosts
echo "192.168.20.10   r-srv   r-srv.skill39.wsr" >> /etc/hosts
echo "192.168.10.2    r-rtr   r-rtr.skill39.wsr" >> /etc/hosts
echo "192.168.100.100 r-cli   r-cli.skill39.wsr" >> /etc/hosts
echo "10.10.10.10     isp" >> /etc/hosts
sysctl -w net.ipv4.ip_forward=1 >> /etc/sysctl.conf

echo -e "
TYPE=ETHERNET
PROXY_METHOD=none
BROWSER_ONLY=no
BOOTPROTO=nope
DEFROUTE=yes
IPV4_FAILURE_FATAL=no
IPV6INIT=no
IPV6_AUTOCONF=yes
IPV6_DEFROUTE=yes
IPV6_FAILURE_FATAL=no
IPV6_ADDR_GEN_MODE=stable-privacy
NAME=ens192
DEVICE=ens192
ONBOOT=yes
IPADDR=192.168.10.2
PREFIX=30
DNS1=192.168.20.10
DOMAIN=skill39.wsr" > /etc/sysconfig/network-scripts/ifcfg-ens192
echo -e "
TYPE=ETHERNET
PROXY_METHOD=none
BROWSER_ONLY=no
BOOTPROTO=nope
IPADDR=192.168.100.1
PREFIX=24
DNS1=192.168.20.10
DOMAIN=skill39.wsr
DEFROUTE=yes
IPV4_FAILURE_FATAL=no
IPV6INIT=no
NAME=ens224
DEVICE=ens224
ONBOOT=yes" > /etc/sysconfig/network-scripts/ifcfg-Wired_connection_1
