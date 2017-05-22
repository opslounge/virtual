##############################################
#
#       Cluster Prep Vmware script
#       This script preps newly build ESX hosts for adding to production
#       Made By Andy Parsons 3-22-2017
#       sanddragon2004 (github)
#       aparsons@purestorage.com
#
##############################################
#This script modifies SSH,NTP, and enables VMOTION
#
#this script will edit the time service for a host in the cluster
Add-PsSnapin VMware.VimAutomation.Core -ea "SilentlyContinue"
#defines what vcenter to connect too. 
connect-viserver -Server demo -User demo -Password password
#defines what cluster to make changes
$cluster = Get-VMHost -Location test


#Edit the $NTPServers variable to create a comma delimited list of the NTP Servers that your ESXi hosts should use
$NTPServers = "ntp1.puretec.purestorage.com"
#====================================
foreach ($ThisHost in $cluster){
    $AllNTP = get-vmhostntpserver -VMHost $ThisHost
    foreach ($ThisNTP in $AllNTP){
        echo "Removing $ThisNTP from $ThisHost"
        remove-vmhostntpserver -VMHost $ThisHost -ntpserver $ThisNTP -Confirm:$false
    }
    foreach ($ThisNTP in $NTPServers){
        echo "Adding $ThisNTP to $ThisHost"
        add-vmhostntpserver -VMHost $ThisHost -ntpserver $ThisNTP -Confirm:$false
    }
    Get-VMHostService -VMHost $ThisHost | where{$_.Key -eq "ntpd"} | restart-vmhostservice -Confirm:$false
    Get-VMHostService -VMHost $ThisHost | where{$_.Key -eq "ntpd"} | set-vmhostservice -policy "on" -Confirm:$false
}


#enable VMOTION on each host in the cluster


foreach ($vmhost in $cluster) {
    
	Get-VMhost $vmhost | Get-VMHostNetworkAdapter -VMKernel | Set-VMHostNetworkAdapter -VMotionEnabled $true -confirm:$false
    
    }


#Enable SSH for each host in the cluster

foreach ($vmhost in $cluster) {
    Get-VMHostService -VMHost $vmhost | Where-Object {$_.Key -eq "TSM"} | Set-VMHostService -policy "on" -Confirm:$false
    Get-VMHostService -VMHost $vmhost | Where-Object {$_.Key -eq "TSM"} | Restart-VMHostService -Confirm:$false
    Get-VMHostService -VMHost $vmhost | Where-Object {$_.Key -eq "TSM-SSH"} | Set-VMHostService -policy "on" -Confirm:$false
    Get-VMHostService -VMHost $vmhost | Where-Object {$_.Key -eq "TSM-SSH"} | Restart-VMHostService -Confirm:$false
 
    Get-VMHost $vmhost| Set-VmHostAdvancedConfiguration -Name UserVars.SuppressShellWarning -Value 1
    Write-Host "Host $vmhost is configured" -ForegroundColor Green
    }

  
