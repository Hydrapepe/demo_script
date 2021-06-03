param ([int] $Stage=1)
function one
{
$action = New-ScheduledTaskAction -Execute 'Powershell.exe' -Argument 'C:\\r1_1.ps1 -Stage 2'
$trigger = New-ScheduledTaskTrigger -AtLogon	
Register-ScheduledTask -Action $action -Trigger $trigger -TaskName "PEPETEST1"
$IntIndex = (Get-NetIPAddress|where{$_.InterfaceAlias -eq 'Ethernet0' -and $_.AddressFamily -eq 'IPv4'}).InterfaceIndex
New-NetIPAddress -InterfaceIndex $IntIndex -IPAddress 172.16.19.126 -PrefixLength 26
Set-DnsClientServerAddress -InterfaceIndex $IntIndex -ServerAddresses 172.16.19.65, 172.16.19.66
$IntIndex2 = (Get-NetIPAddress|where{$_.InterfaceAlias -eq 'Ethernet1' -and $_.AddressFamily -eq 'IPv4'}).InterfaceIndex
New-NetIPAddress -InterfaceIndex $IntIndex2 -IPAddress 200.100.100.2 -PrefixLength 30 -DefaultGateway 200.100.100.1
Rename-Computer -NewName R1 -Force
Restart-Computer -Force
}
function two {
Unregister-ScheduledTask -TaskName "PEPETEST1" -Confirm:$false
Add-Computer -DomainName kazan.wsr -Credential KAZAN\Administrator -restart -force
}
if($Stage -eq 1) 
{
one
}
if($Stage -eq 2) 
{
two
}

