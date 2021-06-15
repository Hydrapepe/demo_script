#!/bin/bash
apt-cdrom add
hostnamectl set-hostname L-SRV
apt install -y tcpdump net-tools curl vim lynx isc-dhcp-common dnsutils nfs-common cifs-utils sshpass openssh-server bash-completion bind9 rsync
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
sed '/PermitRootLogin/d' -i /etc/ssh/sshd_config
echo -e 'PermitRootLogin yes' >> /etc/ssh/sshd_config
echo -e "auto lo
iface lo inet loopback

auto ens192
iface ens192 inet static
address 172.16.20.10
netmask 255.255.255.0
nameservers 127.0.0.1
gateway 172.16.20.1
domain-search skills39.wsr" > /etc/network/interfaces
systemctl disable --now apparmor
##### BIND TEST
<< --MULTILINE-COMMENT--
echo -e '
options {
  directory "/var/cache/bind";
  forwarders {
    10.10.10.10;
  };
  dnssec-validation no;
  listen-on-v6 { any; };
};' > /etc/bind/named.conf.options
mkdir /opt/dns
cp /etc/bind/db.local /opt/dns/skill39.db
cp /etc/bind/db.127 /opt/dns/db.172
cp /etc/bind/db.127 /opt/dns/db.192
chown -R bind:bind /opt/dns
echo -e '
zone "." {
  type hint;
  file "/usr/share/dns/root.hints"
};
zone "skill39.wsr" {
   type master;
   allow-transfer { any; };
   file "/opt/dns/skill39.db";
};

zone "16.172.in-addr.arpa" {
   type master;
   allow-transfer { any; };
   file "/opt/dns/db.172";
};

allow-update { 172.16.50.2; };

zone "20.168.192.in-addr.arpa" {
   type master;
   allow-transfer { any; };
   file "/opt/dns/db.192";
};' > /etc/bind/named.conf.default-zones
--MULTILINE-COMMENT--
echo -e '
module(load="imuxsock") # provides support for local system logging
module(load="imklog")   # provides kernel logging support
module(load="immark")  # provides --MARK-- message capability

module(load="imudp")
input(type="imudp" port="514")

module(load="imtcp")
input(type="imtcp" port="514")

$ActionFileDefaultTemplate RSYSLOG_TraditionalFileFormat

$FileOwner root
$FileGroup adm
$FileCreateMode 0640
$DirCreateMode 0755
$Umask 0022

$WorkDirectory /var/spool/rsyslog

$IncludeConfig /etc/rsyslog.d/*.conf

auth.*\t/opt/logs/L-SRV/auth.log
if $hostname contains "L-FW" or $fromhost-ip contains "172.16.20.1" then {
*.err\t/opt/logs/L-FW/error.log
}
' > /etc/rsyslog.conf
service rsyslog restart
mkdir /opt/sync
useradd mrsync
echo mrsync:toor | chpasswd
chown mrsync /opt/sync
sed '/RSYNC_ENABLE/d' -i /etc/default/rsync
echo -e 'RSYNC_ENABLE=TRUE' >> /etc/default/rsync
echo -e '
[data]
\tuid=mrsync
\tread only=false
\tpath=/opt/sync
\tauth users=sync
\tsecrets file=/etc/rsyncd.secrets
\thosts allow=L-CLI-A.skill39.wsr, L-CLI-B.skill39.wsr
\thosts deny=*
' > /etc/rsyncd.conf
echo sync:parol666 > /etc/rsyncd.secrets
chmod 400 /etc/rsyncd.secrets
systemctl enable --now rsync
systemctl restart rsync
