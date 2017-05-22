# Read MyVLANs.csv for input and create virtual machine portgroups 
# Input file has a header row which contains cluster,vSwitch,VLANname,VLANid 
# The virtual machine port groups will be created on all hosts in the cluster
# If the virtual port group exists it will be skipped but will write errors to the console


# Set the input file
$InputFile = "MyVLANs.csv"

# Read the import file
$MyVLANFile = Import-CSV $InputFile

# Parse the input file and add the virtual port groups accordingly
ForEach ($VLAN in $MyVLANFile) {
	$MyCluster = $VLAN.cluster
	$MyvSwitch = $VLAN.vSwitch
	$MyVLANname = $VLAN.VLANname
	$MyVLANid = $VLAN.VLANid

	# Query the cluster to retrieve the hosts
	$MyVMHosts = Get-Cluster $MyCluster | Get-VMHost | sort Name | % {$_.Name}
	
	# Loop through the hosts and add the virtual port group to our vswitch based on the input
	ForEach ($VMHost in $MyVMHosts) {
		Get-VirtualSwitch -VMHost $VMHost -Name $MyvSwitch | New-VirtualPortGroup -Name $MyVLANname -VLanId $MyVLANid
	}
}

