param ([int] $Stage=1)
function one
{
if  (-not(Test-Path -Path C:\r2_1.ps1 -PathType Leaf)) {
	copy .\r2_1.ps1 C:\
} else {
	echo popa
}
$action = New-ScheduledTaskAction -Execute 'Powershell.exe' -Argument 'C:\\r2_1.ps1 -Stage 2'
$trigger = New-ScheduledTaskTrigger -AtLogon	
Register-ScheduledTask -Action $action -Trigger $trigger -TaskName "PEPETEST1"
$IntIndex = (Get-NetIPAddress|where{$_.InterfaceAlias -eq 'Ethernet0' -and $_.AddressFamily -eq 'IPv4'}).InterfaceIndex
New-NetIPAddress -InterfaceIndex $IntIndex -IPAddress 172.16.20.126 -PrefixLength 27
Set-DnsClientServerAddress -InterfaceIndex $IntIndex -ServerAddresses 172.16.20.97
$IntIndex2 = (Get-NetIPAddress|where{$_.InterfaceAlias -eq 'Ethernet1' -and $_.AddressFamily -eq 'IPv4'}).InterfaceIndex
New-NetIPAddress -InterfaceIndex $IntIndex2 -IPAddress 200.100.100.1 -PrefixLength 30 -DefaultGateway 200.100.100.2
Rename-Computer -NewName R2 -Force
Restart-Computer -Force
}
function two {
Unregister-ScheduledTask -TaskName "PEPETEST1" -Confirm:$false
Add-Computer -DomainName SPB.wse -Credential SPB\Administrator -restart -force
}
if($Stage -eq 1) 
{
one
}
if($Stage -eq 2) 
{
two
}

