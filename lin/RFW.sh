#!/bin/bash
hostnamectl set-hostname R-FW
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
yum -y install tcpdump net-tools curl vim lynx dhclient bind-utils nfs-utils cifs-utils nano bash-completion mc iptables iptables-services
echo -e "\n172.16.20.10    l-srv   l-srv.itnsa39.wsr" >> /etc/hosts
echo "10.10.10.1      l-fw    l-fw.itnsa39.wsr" >> /etc/hosts
echo "172.16.50.2     l-rtr-a l-rtr-a.itnsa39.wsr" >> /etc/hosts
echo "172.16.55.2     l-rtr-b l-rtr-b.itnsa39.wsr" >> /etc/hosts
echo "172.16.200.61   l-cli-b l-cli-b.itnsa39.wsr" >> /etc/hosts
echo "20.20.20.5      out-cli out-cli.itnsa39.wsr" >> /etc/hosts
echo "20.20.20.100    r-fw    r-fw.itnsa39.wsr" >> /etc/hosts
echo "192.168.20.10   r-srv   r-srv.itnsa39.wsr" >> /etc/hosts
echo "192.168.10.2    r-rtr   r-rtr.itnsa39.wsr" >> /etc/hosts
echo "192.168.100.100 r-cli   r-cli.itnsa39.wsr" >> /etc/hosts
echo "10.10.10.10     isp" >> /etc/hosts
sysctl -w net.ipv4.ip_forward=1 >> /etc/sysctl.conf
sed '/PermitRootLogin/d' -i /etc/ssh/sshd_config
echo -e 'PermitRootLogin yes' >> /etc/ssh/sshd_config
sed '/hosts/d' -i /etc/nsswitch.conf
echo -e 'hosts:\tdns files myhostname' >> /etc/nsswitch.conf
sed '/SELINUX/d' -i /etc/selinux/config
echo -e 'SELINUX=disabled' >> /etc/selinux/config
firewall-cmd --zone=external --add-interface=ens192 --permanent
firewall-cmd --zone=external --add-service=gre --permanent
firewall-cmd --zone=trusted --add-interface=ens224 --permanent
firewall-cmd --zone=trusted --add-interface=ens256 --permanent
firewall-cmd --reload
echo -e '
#!/bin/bash
ip tunnel add tun1 mode gre local 20.20.20.100 remote 10.10.10.1 ttl 255
ip link set tun1 up
ip addr add 10.5.5.2/30 dev tun1' > /etc/gre.up
chmod +x /etc/gre.up
echo -e '@reboot root /etc/gre.up' >> /etc/crontab