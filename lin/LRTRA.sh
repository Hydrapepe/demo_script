#!/bin/bash
apt-cdrom add
hostnamectl set-hostname L-RTR-A
apt install -y tcpdump net-tools curl vim lynx isc-dhcp-common dnsutils nfs-common cifs-utils sshpass openssh-server bash-completion
echo "172.16.20.10    l-srv   l-srv.skill39.wsr
10.10.10.1      l-fw    l-fw.skill39.wsr
172.16.50.2     l-rtr-a l-rtr-a.skill39.wsr
172.16.55.2     l-rtr-b l-rtr-b.skill39.wsr
172.16.200.61   l-cli-b l-cli-b.skill39.wsr
20.20.20.5      out-cli out-cli.skill39.wsr
20.20.20.100    r-fw    r-fw.skill39.wsr
192.168.20.10   r-srv   r-srv.skill39.wsr
192.168.10.2    r-rtr   r-rtr.skill39.wsr
192.168.100.100 r-cli   r-cli.skill39.wsr
10.10.10.10     isp" > /etc/hosts
