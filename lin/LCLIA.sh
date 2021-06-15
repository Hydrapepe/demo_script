#!/bin/bash
systemctl disable --now apparmor
apt-cdrom add
hostnamectl set-hostname L-CLI-A
apt install -y tcpdump net-tools curl vim lynx isc-dhcp-common dnsutils nfs-common cifs-utils sshpass openssh-server bash-completion rsync iptables-persistent
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
sed '/hosts/d' -i /etc/nsswitch.conf
echo -e 'hosts:\tdns files' >> /etc/nsswitch.conf
sed '/PermitRootLogin/d' -i /etc/ssh/sshd_config
echo -e 'PermitRootLogin yes' >> /etc/ssh/sshd_config
echo -e "auto lo
iface lo inet loopback
auto ens192
iface ens192 inet dhcp" > /etc/network/interfaces
echo parol666 > /etc/pass
chmod 400 /etc/pass
mkdir /root/sync
echo -e '
#!/bin/bash
rsync -avz --password-file /etc/pass -O /root/sync sync@l-srv.itnsa39.wsr::data
' > /root/sync.sh
chmod +x /root/sync.sh
echo -e '!!!!!!!!!!!! NE zabud proverit rsync 
zapusti ./root/sync.sh kogda zapustish vse sripty'
