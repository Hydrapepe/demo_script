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
Unregister-ScheduledTask -TaskName "PEPETEST1" -Confirm:$false
cmd /c 'mkdir C:\profiles'
Add-Computer -DomainName spb.wsr -Credential SPB\Administrator -restart -force
}
if($Stage -eq 1) 
{
one
}
if($Stage -eq 2) 
{
two
}
