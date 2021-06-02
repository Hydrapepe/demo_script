param ([int] $Stage=1)
function one
{
$action = New-ScheduledTaskAction -Execute 'Powershell.exe' -Argument 'C:\\srv2_1.ps1 -Stage 2'
$trigger = New-ScheduledTaskTrigger -AtLogon	
Register-ScheduledTask -Action $action -Trigger $trigger -TaskName "PEPETEST1"
$IntIndex = (Get-NetIPAddress|where{$_.InterfaceAlias -eq 'Ethernet0' -and $_.AddressFamily -eq 'IPv4'}).InterfaceIndex
New-NetIPAddress -InterfaceIndex $IntIndex -IPAddress 172.16.20.98 -PrefixLength 27 -DefaultGateway 172.16.20.126
Set-DnsClientServerAddress -InterfaceIndex $IntIndex -ServerAddresses 172.16.20.97
Rename-Computer -NewName SRV2 -Force
Restart-Computer -Force
}
function two {
$action = New-ScheduledTaskAction -Execute 'Powershell.exe' -Argument 'C:\\srv2_1.ps1 -Stage 3'
$trigger = New-ScheduledTaskTrigger -AtLogon
Register-ScheduledTask -Action $action -Trigger $trigger -TaskName "PEPETEST2"
Unregister-ScheduledTask -TaskName "PEPETEST1" -Confirm:$false
<#
(echo select volume 0 && echo assign letter=P && echo select disk 1 && echo online disk && echo ATTRIBUTES DISK CLEAR READONLY && echo convert dynamic && echo select disk 2 && echo online disk && echo ATTRIBUTES DISK CLEAR READONLY && echo convert dynamic && echo select disk 3 && echo online disk && echo ATTRIBUTES DISK CLEAR READONLY && echo convert dynamic && echo select disk 4 && echo online disk && echo ATTRIBUTES DISK CLEAR READONLY && echo convert dynamic && echo create volume raid disk=1,2,3,4 && echo format fs=ntfs label="RAID" && echo select volume 3 && echo assign letter=D && echo format quick) > 1.txt && diskpart /s 1.txt
#>
Add-Computer -DomainName spb.wse -Credential SPB\Administrator -restart -force
}
function three {
Import-Module ServerManager
Unregister-ScheduledTask -TaskName "PEPETEST2" -Confirm:$false
Install-WindowsFeature DHCP -IncludeManagementTools
Add-DHCPServerSecurityGroup -ComputerName $env:COMPUTERNAME
Restart-Service dhcpserver
Install-WindowsFeature -Name Web-Server -IncludeAllSubFeature -IncludeManagementTools
Install-WindowsFeature -Name AD-Domain-Services
Install-ADDSDomainController -Credential (Get-Credential) -DomainName "spb.wse" -InstallDNS:$true -ReadOnlyReplica:$true -SiteName "Default-First-Site-Name" -Force:$true
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

