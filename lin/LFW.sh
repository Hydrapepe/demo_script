#!/bin/bash
apt-cdrom add
hostnamectl set-hostname L-FW
apt install -y tcpdump wget net-tools curl vim lynx isc-dhcp-common dnsutils nfs-common cifs-utils sshpass openssh-server bash-completion
iptables-persistent
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
echo -e 'hosts:\tdns files' >> /etc/nsswitch.conf
sysctl -w net.ipv4.ip_forward=1 >> /etc/sysctl.conf
sed '/PermitRootLogin/d' -i /etc/ssh/sshd_config
echo -e 'PermitRootLogin yes' >> /etc/ssh/sshd_config
echo -e 'AllowUsers ssh_p root ssh_c' >> /etc/ssh/sshd_config
adduser ssh_p
adduser ssh_c
echo -e "auto lo
iface lo inet loopback

auto ens192
iface ens192 inet static
address 10.10.10.1
netmask 255.255.255.0
gateway 10.10.10.10
nameservers 172.16.20.10
domain-search demo2020.wsr

auto ens256
iface ens256 inet static
address 172.16.50.1
netmask 255.255.255.252
#gateway 10.10.10.10
nameservers 172.16.20.10
domain-search demo2020.wsr

auto ens224
iface ens224 inet static
address 172.16.20.1
netmask 255.255.255.0
#gateway 10.10.10.10
nameservers 172.16.20.10
domain-search demo2020.wsr

auto ens161
iface ens161 inet static
address 172.16.55.1
netmask 255.255.255.252
#gateway 10.10.10.10
nameservers 172.16.20.10
domain-search demo2020.wsr" > /etc/network/interfaces
#
systemctl disable --now apparmor
iptables -t nat -A POSTROUTING -o ens192 -j MASQUERADE
#
echo '
#!/bin/bash
ip tunnel add tun1 mode gre local 10.10.10.1 remote 20.20.20.100 ttl 255
ip link set tun1 up
ip addr add 10.5.5.1/30 dev tun1' > /etc/gre.up
chmod +x /etc/gre.up
echo -e 'post-up /etc/gre.up' >> /etc/network/interfaces
#### FUNCTION 2
echo -e '*.*@172.16.20.10' >> /etc/rsyslog.conf
service rsyslog restart
