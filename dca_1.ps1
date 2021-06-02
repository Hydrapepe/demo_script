param ([int] $Stage=1)
function one
{
$action = New-ScheduledTaskAction -Execute 'Powershell.exe' -Argument 'C:\\dca_1.ps1 -Stage 2'
$trigger = New-ScheduledTaskTrigger -AtLogon	
Register-ScheduledTask -Action $action -Trigger $trigger -TaskName "PEPETEST1"
$IntIndex = (Get-NetIPAddress|where{$_.InterfaceAlias -eq 'Ethernet0' -and $_.AddressFamily -eq 'IPv4'}).InterfaceIndex
New-NetIPAddress -InterfaceIndex $IntIndex -IPAddress 172.16.19.67 -PrefixLength 26 -DefaultGateway 172.16.19.126
Set-DnsClientServerAddress -InterfaceIndex $IntIndex -ServerAddresses 172.16.19.65, 172.16.19.66
Rename-Computer -NewName DCA -Force
Restart-Computer -Force
}
function two {
$action = New-ScheduledTaskAction -Execute 'Powershell.exe' -Argument 'C:\\dca_1.ps1 -Stage 3'
$trigger = New-ScheduledTaskTrigger -AtLogon
Register-ScheduledTask -Action $action -Trigger $trigger -TaskName "PEPETEST2"
Unregister-ScheduledTask -TaskName "PEPETEST1" -Confirm:$false
Add-Computer -DomainName kazan.wsr -Credential KAZAN\Administrator -restart -force
}
function three {
Import-Module ServerManager
Install-WindowsFeature  AD-Certificate -IncludeAllSubFeature -IncludeManagementTools
Unregister-ScheduledTask -TaskName "PEPETEST2" -Confirm:$false

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
