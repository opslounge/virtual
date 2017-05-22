#adds esx hosts to vcenter using the hosts.csv file. (edit the get datacenter field for different DCs)
#if ( (Get-PSSnapin -Name Vmware.VimAutomation.Core -ErrorAction SilentlyContinue) -eq $null ) {Add-PSSnapin "Vmware.VimAutomation.Core"}
Add-PsSnapin VMware.VimAutomation.Core -ea "SilentlyContinue"
#connect-viserver -Server dev-vc1 -User administrator -Password password
Import-Csv hosts.csv | Foreach-Object { Add-VMHost $_.name -Location (Get-Datacenter demo ) -User root -Password $_.password -RunAsync -force:$true}
