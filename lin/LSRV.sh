#!/bin/bash
apt-cdrom add
hostnamectl set-hostname L-SRV
apt install -y tcpdump net-tools curl vim lynx isc-dhcp-common dnsutils nfs-common cifs-utils sshpass openssh-server bash-completion bind9 rsync iptables-persistent
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
iface ens192 inet static
address 172.16.20.10
netmask 255.255.255.0
nameservers 127.0.0.1
gateway 172.16.20.1
domain-search skills39.wsr" > /etc/network/interfaces
echo -e '
options {
  directory "/var/cache/bind";
  forwarders {
    10.10.10.10;
  };
  dnssec-validation no;
  allow-query { any; };
  listen-on-v6 { any; };
};' > /etc/bind/named.conf.options
mkdir /opt/dns
echo -e '
$TTL	604800
@		IN	SOA	itnsa39.wsr. root.itnsa39.wsr. (
			      2		; Serial
			 604800		; Refresh
			  86400		; Retry
			2419200		; Expire
			 604800 )	; Negative Cache TTL
;
@		IN	NS	l-srv.itnsa39.wsr.
l-srv	IN	A	172.16.20.10
server	IN	CNAME	l-srv.itnsa39.wsr.
l-fw	IN	A	10.10.10.1
r-fw	IN	A	20.20.20.100
www		IN	CNAME	r-fw.itnsa39.wsr.
r-srv	IN	A	192.168.20.10' > /opt/dns/itnsa39.db
echo -e '
$TTL	604800
@		IN	SOA	itnsa39.wsr. root.itnsa39.wsr. (
			      1		; Serial
			 604800		; Refresh
			  86400		; Retry
			2419200		; Expire
			 604800 )	; Negative Cache TTL
;
@		IN	NS	l-srv.itnsa39.wsr.
10.20	IN	PTR	l-srv.itnsa39.wsr.' > /opt/dns/172.db
echo -e '
$TTL	604800
@	IN	SOA	itnsa39.wsr. root.itnsa39.wsr. (
			      1		; Serial
			 604800		; Refresh
			  86400		; Retry
			2419200		; Expire
			 604800 )	; Negative Cache TTL
;
@		IN	NS	l-srv.itnsa39.wsr.
10.20	IN	PTR	l-srv.itnsa39.wsr.' > /opt/dns/192.db
chown -R bind:bind /opt/dns
chown -R bind:bind /opt/dns/
chown -R bind:bind /opt/dns/db.172
chown -R bind:bind /opt/dns/db.192
chown -R bind:bind /opt/dns/itnsa39.db
echo -e '
zone "itnsa39.wsr" {
   type master;
   allow-transfer { any; };
   file "/opt/dns/itnsa39.db";
};

zone "16.172.in-addr.arpa" {
   type master;
   allow-transfer { any; };
   file "/opt/dns/db.172";
};

zone "20.168.192.in-addr.arpa" {
   type master;
   allow-transfer { any; };
   file "/opt/dns/db.192";
};' > /etc/bind/named.conf.default-zones
echo -e '
# vim:syntax=apparmor
# Last Modified: Fri Jun  1 16:43:22 2007
#include <tunables/global>

/usr/sbin/named flags=(attach_disconnected) {
  #include <abstractions/base>
  #include <abstractions/nameservice>

  capability net_bind_service,
  capability setgid,
  capability setuid,
  capability sys_chroot,
  capability sys_resource,

  # See /usr/share/doc/bind9/README.Debian.gz
  /etc/bind/** r,
  /var/lib/bind/** rw,
  /var/lib/bind/ rw,
  /var/cache/bind/** lrw,
  /var/cache/bind/ rw,

  # Database file used by allow-new-zones
  /var/cache/bind/_default.nzd-lock rwk,

  # gssapi
  /etc/krb5.keytab kr,
  /etc/bind/krb5.keytab kr,

  # ssl
  /etc/ssl/openssl.cnf r,

  # root hints from dns-data-root
  /usr/share/dns/root.* r,

  # GeoIP data files for GeoIP ACLs
  /usr/share/GeoIP/** r,

  # dnscvsutil package
  /var/lib/dnscvsutil/compiled/** rw,

  # Allow changing worker thread names
  owner @{PROC}/@{pid}/task/@{tid}/comm rw,

  @{PROC}/net/if_inet6 r,
  @{PROC}/*/net/if_inet6 r,
  @{PROC}/sys/net/ipv4/ip_local_port_range r,
  /usr/sbin/named mr,
  /{,var/}run/named/named.pid w,
  /{,var/}run/named/session.key w,
  # support for resolvconf
  /{,var/}run/named/named.options r,

  # some people like to put logs in /var/log/named/ instead of having
  # syslog do the heavy lifting.
  /var/log/named/** rw,
  /var/log/named/ rw,

  # gssapi
  /var/lib/sss/pubconf/krb5.include.d/** r,
  /var/lib/sss/pubconf/krb5.include.d/ r,
  /var/lib/sss/mc/initgroups r,
  /etc/gss/mech.d/ r,

  # ldap
  /etc/ldap/ldap.conf r,
  /{,var/}run/slapd-*.socket rw,

  # dynamic updates
  /var/tmp/DNS_* rw,

  # dyndb backends
  /usr/lib/bind/*.so rm,

  # Samba DLZ
  /{usr/,}lib/@{multiarch}/samba/bind9/*.so rm,
  /{usr/,}lib/@{multiarch}/samba/gensec/*.so rm,
  /{usr/,}lib/@{multiarch}/samba/ldb/*.so rm,
  /{usr/,}lib/@{multiarch}/ldb/modules/ldb/*.so rm,
  /var/lib/samba/bind-dns/dns.keytab rk,
  /var/lib/samba/bind-dns/named.conf r,
  /var/lib/samba/bind-dns/dns/** rwk,
  /var/lib/samba/private/dns.keytab rk,
  /var/lib/samba/private/named.conf r,
  /var/lib/samba/private/dns/** rwk,
  /etc/samba/smb.conf r,
  /dev/urandom rwmk,
  owner /var/tmp/krb5_* rwk,

  # Site-specific additions and overrides. See local/README for details.
  #include <local/usr.sbin.named>
  /opt/dns/** rw,
}' > /etc/apparmor.d/usr.sbin.named
systemctl restart apparmor.service
systemctl disable --now apparmor
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
useradd rsyncuser
echo rsyncuser:toor | chpasswd
chown rsyncuser /opt/sync
sed '/RSYNC_ENABLE/d' -i /etc/default/rsync
echo -e 'RSYNC_ENABLE=TRUE' >> /etc/default/rsync
echo -e '
[data]
\tuid=rsyncuser
\tread only=false
\tpath=/opt/sync
\tauth users=sync
\tsecrets file=/etc/rsyncd.secrets
\thosts allow=L-CLI-A.itnsa39.wsr, L-CLI-B.itnsa39.wsr
\thosts deny=*
' > /etc/rsyncd.conf
echo sync:P@ssw0rd > /etc/rsyncd.secrets
chmod 400 /etc/rsyncd.secrets
systemctl enable --now rsync
systemctl restart rsync
