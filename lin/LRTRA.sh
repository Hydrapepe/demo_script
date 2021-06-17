#!/bin/bash
apt-cdrom add
hostnamectl set-hostname L-RTR-A
apt install -y tcpdump wget net-tools curl vim lynx isc-dhcp-common dnsutils nfs-common cifs-utils sshpass openssh-server bash-completion isc-dhcp-server
echo "172.16.20.10    l-srv   l-srv.demo2020.wsr
10.10.10.1      l-fw    l-fw.demo2020.wsr
172.16.50.2     l-rtr-a l-rtr-a.demo2020.wsr
172.16.55.2     l-rtr-b l-rtr-b.demo2020.wsr
172.16.200.61   l-cli-b l-cli-b.demo2020.wsr
20.20.20.5      out-cli out-cli.demo2020.wsr
20.20.20.100    r-fw    r-fw.demo2020.wsr
192.168.20.10   r-srv   r-srv.demo2020.wsr
192.168.10.2    r-rtr   r-rtr.demo2020.wsr
192.168.100.100 r-cli   r-cli.demo2020.wsr
10.10.10.10     isp" > /etc/hosts
sed '/PermitRootLogin/d' -i /etc/ssh/sshd_config
echo -e 'PermitRootLogin yes' >> /etc/ssh/sshd_config
sed '/hosts/d' -i /etc/nsswitch.conf
echo -e 'hosts:\tdns files' >> /etc/nsswitch.conf
sysctl -w net.ipv4.ip_forward=1 >> /etc/sysctl.conf
echo -e "auto lo
iface lo inet loopback

auto ens192
iface ens192 inet static
address 172.16.50.2
gateway 172.16.50.1
nameservers 172.16.20.10
domain-search demo2020.wsr
netmask 255.255.255.252

auto ens224
iface ens224 inet static
address 172.16.100.1
nameservers 172.16.20.10
domain-search demo2020.wsr
netmask 255.255.255.0" > /etc/network/interfaces
systemctl disable --now apparmor
echo -e '
#!/bin/bash
ip link add dev lo1 type dummy
ip address add 1.1.1.1/32 dev lo1
ip link set lo1 up' > /etc/loop.up
chmod +x /etc/loop.up
echo -e 'post-up /etc/loop.up' >> /etc/network/interfaces
sed '/INTERFACESv4/d' -i /etc/default/isc-dhcp-server
sed '/INTERFACESv6/d' -i /etc/default/isc-dhcp-server
echo -e 'INTERFACESv4="ens192 ens224"' >> /etc/default/isc-dhcp-server
sed '/authoritative/d' -i /etc/dhcp/dhcpd.conf
echo -e 'authoritative;' >> /etc/dhcp/dhcpd.conf
sed '/option domain-name/d' -i /etc/dhcp/dhcpd.conf
echo -e 'option domain-name "demo2020.wsr";' >> /etc/dhcp/dhcpd.conf
sed '/option domain-name-servers/d' -i /etc/dhcp/dhcpd.conf
echo -e 'option domain-name-servers "172.16.20.10";' >> /etc/dhcp/dhcpd.conf
sed '/ddns-update-style/d' -i /etc/dhcp/dhcpd.conf
echo -e 'ddns-update-style interim;' >> /etc/dhcp/dhcpd.conf
echo -e 'update-static-leases on;' >> /etc/dhcp/dhcpd.conf
echo -e '
subnet 172.16.50.0 netmask 255.255.255.252 {}

subnet 172.16.100.0 netmask 255.255.255.0 {
   range 172.16.100.99 172.16.100.150;
   option routers 172.16.100.1;
}

subnet 172.16.200.0 netmask 255.255.255.0 {
   range 172.16.200.99 172.16.200.150;
   option routers 172.16.200.1;
}

zone demo2020.wsr. {
  primary 172.16.20.10;
}
zone 16.172.in-addr.arpa. {
  primary 172.16.20.10;
}

#host clib {
#  hardware ethernet 00:0c:29:a3:ad:bf;
#  fixed-address 172.16.200.61;
#}' >> /etc/dhcp/dhcpd.conf
echo -e '\033[0;31m !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!\033[0m'
echo -e '\033[0;31m !!!!!!!!!ZAYDI V /etc/dhcp/dhcpd.conf I POFIKSI L-CLI-B MAC ADDRESS V SAMOM NIZU!!!!!!!!  \033[0m'
echo -e '\033[0;31m !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!\033[0m'
systemctl restart isc-dhcp-server
systemctl enable isc-dhcp-server
