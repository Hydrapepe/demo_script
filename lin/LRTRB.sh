#!/bin/bash
apt-cdrom add
hostnamectl set-hostname L-RTR-B
apt install -y tcpdump wget net-tools curl vim lynx isc-dhcp-common dnsutils nfs-common cifs-utils sshpass openssh-server bash-completion
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
sed '/PermitRootLogin/d' -i /etc/ssh/sshd_config
echo -e 'PermitRootLogin yes' >> /etc/ssh/sshd_config
sysctl -w net.ipv4.ip_forward=1 >> /etc/sysctl.conf
echo -e "auto lo
iface lo inet loopback

auto ens192
iface ens192 inet static
address 172.16.55.2
gateway 172.16.55.1
nameservers 172.16.20.10
domain-search demo2020.wsr
netmask 255.255.255.252

auto ens224
iface ens224 inet static
address 172.16.200.1
nameservers 172.16.20.10
domain-search demo2020.wsr
netmask 255.255.255.0" > /etc/network/interfaces
systemctl disable --now apparmor
echo -e '
#!/bin/bash
ip link add dev lo1 type dummy
ip address add 2.2.2.2/32 dev lo1
ip link set lo1 up' > /etc/loop.up
chmod +x /etc/loop.up
echo -e 'post-up /etc/loop.up' >> /etc/network/interfaces
echo -e '\033[0;31m !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!\033[0m'
echo -e '\033[0;31m !!!!!!!!!USTANOVITE isc-dhcp-relay so vtorogo diska, ip 172.16.50.2, interfaces ens192 ens224!!!!!!!!  \033[0m'
echo -e '\033[0;31m !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!\033[0m'
