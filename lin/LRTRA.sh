#!/bin/bash
apt-cdrom add
hostnamectl set-hostname L-RTR-A
apt install -y tcpdump net-tools curl vim lynx isc-dhcp-common dnsutils nfs-common cifs-utils sshpass openssh-server bash-completion isc-dhcp-server
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
domain-search skills39.wsr
netmask 255.255.255.252

auto ens224
iface ens224 inet static
address 172.16.100.1
nameservers 172.16.20.10
domain-search skills39.wsr
netmask 255.255.255.0" > /etc/network/interfaces
systemctl disable --now apparmor

echo -e '
#!/bin/bash
ip link add dev lo1 type dummy
ip address add 1.1.1.1/32 dev lo1
ip link set lo1 up' > /etc/loop.up
chmod +x /etc/loop.up
echo -e 'post-up /etc/loop.up' >> /etc/network/interfaces


