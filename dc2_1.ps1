param ([int] $Stage=1)
function one
{
$action = New-ScheduledTaskAction -Execute 'Powershell.exe' -Argument 'C:\\dc2_1.ps1 -Stage 2'
$trigger = New-ScheduledTaskTrigger -AtLogon
$IntIndex = (Get-NetIPAddress|where{$_.InterfaceAlias -eq 'Ethernet0' -and $_.AddressFamily -eq 'IPv4'}).InterfaceIndex
Register-ScheduledTask -Action $action -Trigger $trigger -TaskName "PEPETEST1"
New-NetIPAddress -InterfaceIndex $IntIndex -IPAddress 172.16.20.97 -PrefixLength 27 -DefaultGateway 172.16.20.126
Set-DnsClientServerAddress -InterfaceIndex $IntIndex -ServerAddresses 172.16.20.97
Rename-Computer -NewName DC2 -Force
Restart-Computer -Force
}
function two 
{$action = New-ScheduledTaskAction -Execute 'Powershell.exe' -Argument 'C:\\dc2_1.ps1 -Stage 3'
$trigger = New-ScheduledTaskTrigger -AtLogon
Register-ScheduledTask -Action $action -Trigger $trigger -TaskName "PEPETEST2"
Unregister-ScheduledTask -TaskName "PEPETEST1" -Confirm:$false
Import-Module ServerManager
Add-WindowsFeature -Name AD-Domain-Services -IncludeAllSubFeature -IncludeManagementTools
Import-Module ADDSDeployment
Install-ADDSForest -CreateDnsDelegation:$false -DatabasePath "C:\Windows\NTDS" -DomainMode "Win2012" -DomainName "SPB.wsr" -DomainNetbiosName SPB -ForestMode "Win2012" -InstallDns:$true -LogPath "C:\Windows\NTDS" -NoRebootOnCompletion:$false -SysvolPath "C:\Windows\SYSVOL" -Force:$true -SafeModeAdministratorPassword (convertto-securestring P@ssw0rd -asplaintext -force)
}
function three 
{
$action = New-ScheduledTaskAction -Execute 'Powershell.exe' -Argument 'C:\\dc2_1.ps1 -Stage 4'
$trigger = New-ScheduledTaskTrigger -AtLogon	
Register-ScheduledTask -Action $action -Trigger $trigger -TaskName "PEPETEST3"
Unregister-ScheduledTask -TaskName "PEPETEST2" -Confirm:$false
Install-WindowsFeature -name Web-Server -IncludeManagementTools
Install-WindowsFeature -Name NET-Framework-45-ASPNET
Enable-WindowsOptionalFeature -Online -FeatureName IIS-ManagementService
Add-DnsServerPrimaryZone -DynamicUpdate NonsecureAndSecure -NetworkId "172.16.20.0/24" -ReplicationScope Domain
Add-DnsServerResourceRecordPtr -Name "97" -ZoneName "20.16.172.in-addr.arpa" -AgeRecord -PtrDomainName "$env:COMPUTERNAME.spb.wsr"
Add-DnsServerResourceRecordA -Name www -IPv4Address 172.16.20.98 -ZoneName SPB.wsr -TimeToLive 01:00:00
Add-DNSServerResourceRecordPTR -ZoneName 20.16.172.in-addr.arpa -Name 98 -PTRDomainName www.spb.wsr
Import-Module ServerManager
Add-WindowsFeature -Name DHCP -IncludeManagementTools
Add-DHCPServerSecurityGroup -ComputerName $env:COMPUTERNAME
Restart-Service dhcpserver
Add-DhcpServerInDC -DnsName $env:COMPUTERNAME -IPAddress 172.16.20.97
$itname ="User1"
$itpass = "P@ssw0rd"
$domen ="SPB.wsr"
$itparam = ConvertTo-SecureString -String $itpass -AsPlainText -Force
New-ADUser -Name $itname  -Enabled $true -Path 'OU=Users,DC=spb,DC=wsr' -AccountPassword $itparam -UserPrincipalName $itname@$domen
$User = "$env:USERDOMAIN\$env:USERNAME"
$PWord = ConvertTo-SecureString -String P@ssw0rd -AsPlainText -Force
$Credential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $User, $PWord
Set-DHCPServerDnsCredential -ComputerName $env:COMPUTERNAME -Credential $Credential
Add-DHCPServerv4Scope -Name Pool11 -StartRange 172.16.20.99 -EndRange 172.16.20.125 -SubnetMask 255.255.255.224 -State Active
Set-DHCPServerv4OptionValue -ComputerName $env:COMPUTERNAME -DnsServer 172.16.20.97 -DnsDomain SPB.wsr -Router 172.16.20.126
Set-DHCPServerv4OptionValue -ComputerName $env:COMPUTERNAME -ScopeId 97 -DnsServer 172.16.20.97 -DnsDomain SPB.wsr -Router 172.16.20.126
Restart-Computer -Force
}
function foure 
{
Unregister-ScheduledTask -TaskName "PEPETEST3" -Confirm:$false
Import-Module activedirectory
New-GPO -Name "Sleep"
Set-GPRegistryValue -Name "Sleep" -Key "HKLM\Software\Policies\Microsoft\Power\PowerSettings" -ValueName ActivePowerScheme -Type String -Value '8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c'
New-GPLink -Name "Sleep" -Target "DC=spb,DC=wsr" 
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