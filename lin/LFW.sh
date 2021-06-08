#!/bin/bash
apt-cdrom add
hostnamectl set-hostname L-FW
apt install -y tcpdump net-tools curl vim lynx isc-dhcp-common dnsutils nfs-common cifs-utils sshpass openssh-server bash-completion
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
sed '/hosts/d' -i /etc/nsswitch.conf
echo -e 'hosts:\tdns files' >> /etc/nsswitch.conf
sysctl -w net.ipv4.ip_forward=1 >> /etc/sysctl.conf

echo -e "auto lo
iface lo inet loopback

auto ens192
iface ens192 inet static
address 10.10.10.1
netmask 255.255.255.0
gateway 10.10.10.10
nameservers 172.16.20.10
domain-search skills39.wsr

auto ens256
iface ens256 inet static
address 172.16.50.1
netmask 255.255.255.252
#gateway 10.10.10.10
nameservers 172.16.20.10
domain-search skills39.wsr

auto ens224
iface ens224 inet static
address 172.16.20.1
netmask 255.255.255.0
#gateway 10.10.10.10
nameservers 172.16.20.10
domain-search skills39.wsr

auto ens161
iface ens161 inet static
address 172.16.55.1
netmask 255.255.255.0
#gateway 10.10.10.10
nameservers 172.16.20.10
domain-search skills39.wsr" > /etc/network/interfaces

