param ([int] $Stage=1)
function one
{
$action = New-ScheduledTaskAction -Execute 'Powershell.exe' -Argument 'C:\\srv1_1.ps1 -Stage 2'
$trigger = New-ScheduledTaskTrigger -AtLogon	
Register-ScheduledTask -Action $action -Trigger $trigger -TaskName "PEPETEST1"
$IntIndex = (Get-NetIPAddress|where{$_.InterfaceAlias -eq 'Ethernet0' -and $_.AddressFamily -eq 'IPv4'}).InterfaceIndex
New-NetIPAddress -InterfaceIndex $IntIndex -IPAddress 172.16.19.66 –PrefixLength 26 -DefaultGateway 172.16.19.126
Set-DnsClientServerAddress -InterfaceIndex $IntIndex -ServerAddresses 172.16.19.65, 172.16.19.66
Rename-Computer -NewName SRV1 -Force
Restart-Computer -Force
}
function two {
	Unregister-ScheduledTask -TaskName "PEPETEST1" -Confirm:$false
(echo select volume 0 && echo assign letter=P && echo select disk 1 && echo online disk && echo ATTRIBUTES DISK CLEAR READONLY && echo convert dynamic && echo select disk 2 && echo online disk && echo ATTRIBUTES DISK CLEAR READONLY && echo convert dynamic && echo select disk 3 && echo online disk && echo ATTRIBUTES DISK CLEAR READONLY && echo convert dynamic && echo select disk 4 && echo online disk && echo ATTRIBUTES DISK CLEAR READONLY && echo convert dynamic && echo create volume raid disk=1,2,3,4 && echo format fs=ntfs label="RAID" && echo select volume 3 && echo assign letter=D && echo format quick) > 1.txt && diskpart /s 1.txt
}
if($Stage -eq 1) 
{
one
}
if($Stage -eq 2) 
{
two
}


#Add-Computer -DomainName kazan.wsr -Credential KAZAN\Administrator -restart -force