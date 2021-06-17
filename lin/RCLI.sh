#!/bin/bash
hostnamectl set-hostname R-CLI
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
yum -y install tcpdump wget net-tools curl vim lynx dhclient bind-utils nfs-utils cifs-utils nano bash-completion mc iptables iptables-services
echo -e "\n172.16.20.10    l-srv   l-srv.demo2020.wsr" >> /etc/hosts
echo "10.10.10.1      l-fw    l-fw.demo2020.wsr" >> /etc/hosts
echo "172.16.50.2     l-rtr-a l-rtr-a.demo2020.wsr" >> /etc/hosts
echo "172.16.55.2     l-rtr-b l-rtr-b.demo2020.wsr" >> /etc/hosts
echo "172.16.200.61   l-cli-b l-cli-b.demo2020.wsr" >> /etc/hosts
echo "20.20.20.5      out-cli out-cli.demo2020.wsr" >> /etc/hosts
echo "20.20.20.100    r-fw    r-fw.demo2020.wsr" >> /etc/hosts
echo "192.168.20.10   r-srv   r-srv.demo2020.wsr" >> /etc/hosts
echo "192.168.10.2    r-rtr   r-rtr.demo2020.wsr" >> /etc/hosts
echo "192.168.100.100 r-cli   r-cli.demo2020.wsr" >> /etc/hosts
echo "10.10.10.10     isp" >> /etc/hosts
sed '/hosts/d' -i /etc/nsswitch.conf
echo -e 'hosts:\tdns files myhostname' >> /etc/nsswitch.conf
sed '/PermitRootLogin/d' -i /etc/ssh/sshd_config
echo -e 'PermitRootLogin yes' >> /etc/ssh/sshd_config
echo -e '\033[0;31m !!!!!!!!!!!!!!! Postav ip 192.168.100.100 mask 24 na ens192, gateway 192.168.100.1, dns 172.16.20.10, domain demo2020.wsr \033[0m'