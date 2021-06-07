param ([int] $Stage=1)
function one
{
if  (-not(Test-Path -Path C:\dc1_1.ps1 -PathType Leaf)) {
	copy .\dc1_1.ps1 C:\
} else {
	echo popa
}
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
Install-ADDSForest -CreateDnsDelegation:$false -DatabasePath "C:\Windows\NTDS" -DomainMode "Win2012" -DomainName "kazan.wsr" -DomainNetbiosName KAZAN -ForestMode "Win2012" -InstallDns:$true -LogPath "C:\Windows\NTDS" -NoRebootOnCompletion:$false -SysvolPath "C:\Windows\SYSVOL" -Force:$true -SafeModeAdministratorPassword (convertto-securestring P@ssw0rd -asplaintext -force)
}
function three 
{
$action = New-ScheduledTaskAction -Execute 'Powershell.exe' -Argument 'C:\\dc1_1.ps1 -Stage 4'
$trigger = New-ScheduledTaskTrigger -AtLogon	
Register-ScheduledTask -Action $action -Trigger $trigger -TaskName "PEPETEST3"	
Unregister-ScheduledTask -TaskName "PEPETEST2" -Confirm:$false
Add-DnsServerPrimaryZone -DynamicUpdate NonsecureAndSecure -NetworkId "172.16.19.0/24" -ReplicationScope Domain
Add-DnsServerResourceRecordPtr -Name "65" -ZoneName "19.16.172.in-addr.arpa" -AgeRecord -PtrDomainName "$env:COMPUTERNAME.kazan.wsr"
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
Set-DHCPServerv4OptionValue -ComputerName $env:COMPUTERNAME -DnsServer 172.16.19.65 -DnsDomain kazan.wsr -Router 172.16.19.126
Set-DHCPServerv4OptionValue -ComputerName $env:COMPUTERNAME -ScopeId 65 -DnsServer 172.16.19.65 -DnsDomain kazan.wsr -Router 172.16.19.126
Restart-Computer -Force
}
function foure 
{
Unregister-ScheduledTask -TaskName "PEPETEST3" -Confirm:$false
Start-Sleep -s 30
Import-Module activedirectory
New-ADOrganizationalUnit -Name "IT"
New-ADOrganizationalUnit -Name "Sales"
New-ADGroup "IT" -path 'OU=IT,DC=kazan,DC=wsr' -GroupScope Global -PassThru –Verbose
New-ADGroup "Sales" -path 'OU=Sales,DC=kazan,DC=wsr' -GroupScope Global -PassThru –Verbose
for ($i = 1; $i -le 30; $i++){
$itname ="IT_" +$i
$itpass = "P@ssw0rd" + $i
$domen ="kazan.wsr"
$itparam = ConvertTo-SecureString -String $itpass -AsPlainText -Force
New-ADUser -Name $itname  -Enabled $true -Path 'OU=IT,DC=kazan,DC=wsr' -AccountPassword $itparam -UserPrincipalName $itname@$domen
Add-ADGroupMember -Identity IT -Members $itname
$salesname ="Sales_" +$i
$salespass = "P@ssw0rd"+$i
$salesparam = ConvertTo-SecureString -String $salespass -AsPlainText -Force
New-ADUser -Name $salesname  -Enabled $true -Path 'OU=Sales,DC=kazan, DC=wsr' -AccountPassword $salesparam -UserPrincipalName $salesname@$domen
Add-ADGroupMember -Identity Sales -Members $salesname
}
New-GPO -Name "First_Animation"
Set-GPRegistryValue -Name "First_Animation" -Key "HKLM\Software\Microsoft\Windows\CurrentVersion\Policies\System" -ValueName EnableFirstLogonAnimation -Type DWord -Value 0
New-GPLink -Name "First_Animation" -Target "DC=kazan,DC=wsr" 
New-GPO -Name "ICMP"
Set-GPRegistryValue -Name "ICMP" -Key "HKLM\Software\Policies\Microsoft\WindowsFirewall" -ValueName PolicyVersion -Type DWord -Value 541
Set-GPRegistryValue -Name "ICMP" -Key "HKLM\Software\Policies\Microsoft\WindowsFirewall\FirewallRules" -ValueName '{39201855-FA74-4AFC-8CBD-BF4C02E57738}' -Type String -Value 'v2.28|Action=Allow|Active=TRUE|Dir=In|Protocol=1|Name=test1in|' 
Set-GPRegistryValue -Name "ICMP" -Key "HKLM\Software\Policies\Microsoft\WindowsFirewall\FirewallRules" -ValueName '{2BC88FE6-B8D9-4DB9-AB38-989CADA48E33}' -Type String -Value 'v2.28|Action=Allow|Active=TRUE|Dir=Out|Protocol=1|Name=testout|'
New-GPLink -Name "ICMP" -Target "DC=kazan,DC=wsr" 
New-GPO -Name "Warning"
Set-GPRegistryValue -Name "Warning" -Key "HKLM\Software\Policies\Microsoft\Windows\ADR\AccessDenied" -ValueName Enabled -Type DWord -Value 1 
Set-GPRegistryValue -Name "Warning" -Key "HKLM\Software\Policies\Microsoft\Windows\ADR\AccessDenied" -ValueName ErrorMessage -Type MultiString -Value 'You do not have permissions to use this path - [Original File Path]! Do not try it again!'
Set-GPRegistryValue -Name "Warning" -Key "HKLM\Software\Policies\Microsoft\Windows\ADR\AccessDenied" -ValueName AllowEmailRequests -Type DWord -Value 1
Set-GPRegistryValue -Name "Warning" -Key "HKLM\Software\Policies\Microsoft\Windows\ADR\AccessDenied" -ValueName EmailMessage -Type MultiString -Value ''
Set-GPRegistryValue -Name "Warning" -Key "HKLM\Software\Policies\Microsoft\Windows\ADR\AccessDenied" -ValueName PutDataOwnerOnTo -Type DWord -Value 1
Set-GPRegistryValue -Name "Warning" -Key "HKLM\Software\Policies\Microsoft\Windows\ADR\AccessDenied" -ValueName PutAdminOnTo -Type DWord -Value 1
Set-GPRegistryValue -Name "Warning" -Key "HKLM\Software\Policies\Microsoft\Windows\ADR\AccessDenied" -ValueName AdditonalEmailTo -Type String -Value ''
Set-GPRegistryValue -Name "Warning" -Key "HKLM\Software\Policies\Microsoft\Windows\ADR\AccessDenied" -ValueName IncludeDeviceClaims -Type DWord -Value 1
Set-GPRegistryValue -Name "Warning" -Key "HKLM\Software\Policies\Microsoft\Windows\ADR\AccessDenied" -ValueName IncludeUserClaims -Type DWord -Value 1
Set-GPRegistryValue -Name "Warning" -Key "HKLM\Software\Policies\Microsoft\Windows\ADR\AccessDenied" -ValueName GenerateLog -Type DWord -Value 1
Set-GPRegistryValue -Name "Warning" -Key "HKLM\Software\Policies\Microsoft\Windows\Explorer" -ValueName EnableShellExecuteFileStreamCheck -Type DWord -Value 1
New-GPLink -Name "Warning" -Target "DC=kazan,DC=wsr" 
}
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
