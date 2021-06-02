param ([int] $Stage=1)
function one
{
$action = New-ScheduledTaskAction -Execute 'Powershell.exe' -Argument 'C:\\dc1_1.ps1 -Stage 2'
$trigger = New-ScheduledTaskTrigger -AtLogon
$IntIndex = (Get-NetIPAddress|where{$_.InterfaceAlias -eq 'Ethernet0' -and $_.AddressFamily -eq 'IPv4'}).InterfaceIndex
Register-ScheduledTask -Action $action -Trigger $trigger -TaskName "PEPETEST1"
New-NetIPAddress -InterfaceIndex $IntIndex -IPAddress 172.16.19.65 –PrefixLength 26 -DefaultGateway 172.16.19.126
Set-DnsClientServerAddress -InterfaceIndex $IntIndex -ServerAddresses 172.16.19.65, 172.16.19.66
Rename-Computer -NewName DC1 -Force
Restart-Computer -Force
}
function two 
{$action = New-ScheduledTaskAction -Execute 'Powershell.exe' -Argument 'C:\\dc1_1.ps1 -Stage 3'
$trigger = New-ScheduledTaskTrigger -AtLogon
Register-ScheduledTask -Action $action -Trigger $trigger -TaskName "PEPETEST2"
Unregister-ScheduledTask -TaskName "PEPETEST1" -Confirm:$false
Import-Module ServerManager
Add-WindowsFeature –Name AD-Domain-Services –IncludeAllSubFeature –IncludeManagementTools
Import-Module ADDSDeployment
Install-ADDSForest -CreateDnsDelegation:$false -DatabasePath "C:\Windows\NTDS" -DomainMode "Win2012" -DomainName "Kazan.wsr" -DomainNetbiosName KAZAN -ForestMode "Win2012" -InstallDns:$true -LogPath "C:\Windows\NTDS" -NoRebootOnCompletion:$false -SysvolPath "C:\Windows\SYSVOL" -Force:$true -SafeModeAdministratorPassword (convertto-securestring Windows1 -asplaintext -force)
}
function three 
{
$action = New-ScheduledTaskAction -Execute 'Powershell.exe' -Argument 'C:\\dc1_1.ps1 -Stage 4'
$trigger = New-ScheduledTaskTrigger -AtLogon	
Register-ScheduledTask -Action $action -Trigger $trigger -TaskName "PEPETEST3"	
Unregister-ScheduledTask -TaskName "PEPETEST2" -Confirm:$false
Add-DnsServerPrimaryZone -DynamicUpdate NonsecureAndSecure -NetworkId "172.16.19.0/24" -ReplicationScope Domain
Add-DnsServerResourceRecordPtr -Name "65" -ZoneName "19.16.172.in-addr.arpa" -AgeRecord -PtrDomainName "$env:COMPUTERNAME.Kazan.wsr"
Add-DnsServerResourceRecordA -Name www -IPv4Address 172.16.19.66 -ZoneName kazan.wsr -TimeToLive 01:00:00
Add-DNSServerResourceRecordPTR -ZoneName 19.16.172.in-addr.arpa -Name 66 -PTRDomainName www.kazan.wsr
Import-Module ServerManager
Add-WindowsFeature –Name DHCP –IncludeManagementTools
Add-DHCPServerSecurityGroup -ComputerName $env:COMPUTERNAME
Restart-Service dhcpserver
Add-DhcpServerInDC -DnsName $env:COMPUTERNAME -IPAddress 172.16.19.65
$User = "$env:USERDOMAIN\$env:USERNAME"
$PWord = ConvertTo-SecureString -String P@ssw0rd -AsPlainText -Force
$Credential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $User, $PWord
Set-DHCPServerDnsCredential -ComputerName $env:COMPUTERNAME -Credential $Credential
Add-DHCPServerv4Scope -Name Pool1 -StartRange 172.16.19.68 -EndRange 172.16.19.125 -SubnetMask 255.255.255.192 -State Active
Set-DHCPServerv4OptionValue -ComputerName $env:COMPUTERNAME -DnsServer 172.16.19.65 -DnsDomain Kazan.wsr -Router 172.16.19.126
Set-DHCPServerv4OptionValue -ComputerName $env:COMPUTERNAME -ScopeId 65 -DnsServer 172.16.19.65 -DnsDomain Kazan.wsr -Router 172.16.19.126
Restart-Computer -Force
}
function foure 
{
Unregister-ScheduledTask -TaskName "PEPETEST3" -Confirm:$false
Import-Module activedirectory
New-ADOrganizationalUnit -Name "IT"
New-ADOrganizationalUnit -Name "Sales"
New-ADGroup "IT" -path 'OU=IT,DC=Kazan,dc=wsr' -GroupScope Global -PassThru –Verbose
New-ADGroup "Sales" -path 'OU=Sales,DC=Kazan,dc=wsr' -GroupScope Global -PassThru –Verbose
for ($i = 1; $i -le 30; $i++){
$itname ="IT_" +$i
$itpass = "P@ssw0rd" + $i
$domen ="Kazan.wsr"
$itparam = ConvertTo-SecureString -String $itpass -AsPlainText -Force
New-ADUser -Name $itname  -Enabled $true -Path ‘OU=IT,DC=Kazan,DC=wsr’ -AccountPassword $itparam -UserPrincipalName $itname@$domen
Add-ADGroupMember -Identity IT -Members $itname
$salesname ="Sales_" +$i
$salespass = "P@ssw0rd"+$i
$salesparam = ConvertTo-SecureString -String $salespass -AsPlainText -Force
New-ADUser -Name $salesname  -Enabled $true -Path ‘OU=Sales,DC=Kazan, DC=wsr’ -AccountPassword $salesparam -UserPrincipalName $salesname@$domen
Add-ADGroupMember -Identity Sales -Members $salesname
}}
if($Stage -eq 1) 
{
one
}
if($Stage -eq 2) 
{
two
}
if($Stage -eq 3) 
{
three
}
if($Stage -eq 4) 
{
foure
}
