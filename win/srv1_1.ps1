param ([int] $Stage=1)
function one
{
if  (-not(Test-Path -Path C:\srv1_1.ps1 -PathType Leaf)) {
	copy .\srv1_1.ps1 C:\
} else {
	echo popa
}
$action = New-ScheduledTaskAction -Execute 'Powershell.exe' -Argument 'C:\\srv1_1.ps1 -Stage 2'
$trigger = New-ScheduledTaskTrigger -AtLogon	
Register-ScheduledTask -Action $action -Trigger $trigger -TaskName "PEPETEST1"
$IntIndex = (Get-NetIPAddress|where{$_.InterfaceAlias -eq 'Ethernet0' -and $_.AddressFamily -eq 'IPv4'}).InterfaceIndex
New-NetIPAddress -InterfaceIndex $IntIndex -IPAddress 172.16.19.66 -PrefixLength 26 -DefaultGateway 172.16.19.126
Set-DnsClientServerAddress -InterfaceIndex $IntIndex -ServerAddresses 172.16.19.65, 172.16.19.66
Rename-Computer -NewName SRV1 -Force
Restart-Computer -Force
}
function two {
$action = New-ScheduledTaskAction -Execute 'Powershell.exe' -Argument 'C:\\srv1_1.ps1 -Stage 3'
$trigger = New-ScheduledTaskTrigger -AtLogon
Register-ScheduledTask -Action $action -Trigger $trigger -TaskName "PEPETEST2"
Unregister-ScheduledTask -TaskName "PEPETEST1" -Confirm:$false
cmd /c '(echo select volume 0 && echo assign letter=P && echo select disk 1 && echo online disk && echo ATTRIBUTES DISK CLEAR READONLY && echo convert dynamic && echo select disk 2 && echo online disk && echo ATTRIBUTES DISK CLEAR READONLY && echo convert dynamic && echo select disk 3 && echo online disk && echo ATTRIBUTES DISK CLEAR READONLY && echo convert dynamic && echo select disk 4 && echo online disk && echo ATTRIBUTES DISK CLEAR READONLY && echo convert dynamic) > 1.txt && diskpart /s 1.txt'
cmd /c 'mkdir D:\shares\departments\it'
cmd /c 'mkdir D:\shares\departments\sales'
cmd /c 'mkdir D:\shares\it'
Add-Computer -DomainName Kazan.wsr -Credential KAZAN\Administrator -restart -force
}
function three {
$User = "KAZAN\Administrator"
$PWord = ConvertTo-SecureString -String P@ssw0rd -AsPlainText -Force
$Credential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $User, $PWord
Import-Module ServerManager
Unregister-ScheduledTask -TaskName "PEPETEST2" -Confirm:$false
Install-WindowsFeature DHCP -IncludeManagementTools
Add-DHCPServerSecurityGroup -ComputerName $env:COMPUTERNAME
Restart-Service dhcpserver
Add-WindowsFeature –Name AD-Domain-Services –IncludeAllSubFeature –IncludeManagementTools
Import-Module ADDSDeployment
Install-ADDSDomainController -NoGlobalCatalog:$false -Credential $Credential -CriticalReplicationOnly:$false -DatabasePath "C:\Windows\NTDS" -DelegatedAdministratorAccountName "KAZAN\Administrator" -DomainName "Kazan.wsr" -InstallDns:$true -LogPath "C:\Windows\NTDS" -NoRebootOnCompletion:$false -ReadOnlyReplica:$true -ReplicationSourceDC "DC1.Kazan.wsr" -SiteName "Default-First-Site-Name" -SysvolPath "C:\Windows\SYSVOL" -Force:$true
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

