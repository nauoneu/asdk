Param(
  [Parameter(Mandatory)]
  [int]$numberOfNics = 2,
  [int]$addSshKey = 0
)

# Make it interactive for the number of NIC
'parameters accepted,'
'[int]numberOfNics = number of nics of the instance (between 1 and 4)'
'[int]addSshKey = 1 for yes, 0 for no. If yes, your key must be provided in the corresponding line.'
'[string]vmsize = examples: Standard_F2s,Standard_F4s,Standard_F8s,Standard_F1,Standard_F2,Standard_F4,Standard_F8'
'`n'
echo "numberOfNics : $numberOfNics"


# Provide your basic profiles
$subscriptionID = "b91ed06d-c6e4-406c-b989-32b013e17a8f"  <# Specify your subscription ID which is entitled to purchase marketplace products #>
$key = "123456789abcdefg$%#@!"                            <# random seed ; any strings will be fine. #>

# Required variables
$resourceGroupName = "turesourcegroup01"  <# Your existing resource group name #>
$virtualNetworkName = "tuvnet02"  <# Your existing Virtual Network name #>
$locationName = "local"  <# Location #>
$user = "fortinet"         <# FortiGate-VM admin username #>
$password = 'Fortinet123$'  <# FortiGate-VM admin password #>
$vmName = "tuFGT01"  <# FortiGate-VM hostname #>
$vmsize = "Standard_F2"     <# FortiGate-VM vmsize. Compute-optimized instance types are recommended #>
$storageAccountName = "tustorage02"   <# Your storage account; make sure this account exists under the resource group you specified #>
$storageAccountKey = "IWEWIepj28nzDJ+X5N5dzKCfBYxyOb25rhxBS3s0VoltVpKm9DJHetv9K+LawvN5IlbSJDF+kHgY+tyR1myqug==" <# Your Storage account key #>
$sourceVhd = "C:\Users\AzureStackAdmin\Documents\Azure\Azure-Templates-master\FortiGate\vhd\623\fortios.vhd"
$destinationVhd = "https://tustorage02.blob.local.azurestack.external/tucontainer01/fortigate.vhd" <# FortiGate-VM OS disk file created in your Azure blob #>
$osDiskUri = "https://tustorage02.blob.local.azurestack.external/osdisk/fortigate.vhd"  <# FortiGate-VM data disk file created in your Azure blob #>
$dataDiskUri = "https://tustorage02.blob.local.azurestack.external/datadisk/DataDisk.vhd"  <# FortiGate-VM data disk file created in your Azure blob #>

$osDiskName = $vmName + '_osDisk'
$dataDiskName = $vmName + '_datadisk'

# Passing the profiles
$SecurePassword = $key | ConvertTo-SecureString -AsPlainText -Force
$DebugPreference="Continue"
$keyData = ""
#$keyData = "ssh-rsa AAAAB3NzaC1yc2EAA...........84Km1/qscePDoXt youradmin"
$networkname1 = "port1" 
$networkname2 = "port2"
$networkname3 = "port3"
$networkname4 = "port4"
$pipName = "tupip01" <# Public IP address name #>

#Add-AzureRmAccount
#Select-AzureRmSubscription -SubscriptionId $SubscriptionId

# Upload your local vhd file to Azure - this is "required" - VHD has to be 2GB in size
Write-Output "$(Get-Date -f $timeStampFormat) - Upload"
Add-AzureRmVhd -LocalFilePath $sourceVHD -Destination $destinationVHD -ResourceGroupName $resourceGroupName -NumberOfUploaderThreads 5

# Find an existing VNet under an existing resource group
$virtualNetwork = Get-AzureRmVirtualNetwork -ResourceGroupName $resourceGroupName -Name $virtualNetworkName

# Create a public IP address
Write-Output "$(Get-Date -f $timeStampFormat) - Create new public ip address"
$publicIp = New-AzureRmPublicIpAddress -Name $pipName -ResourceGroupName $ResourceGroupName -Location $locationName -AllocationMethod Dynamic -force

# Define NICs   
if ($numberOfNics -eq 0){
    'please try again, number of nics should not be 0'
}
ElseIf ($numberOfNics -eq 1){
    Write-Output "$(Get-Date -f $timeStampFormat) - creating 1 nic"
    $networkInterface1 = New-AzureRmNetworkInterface -ResourceGroupName $resourceGroupName -Name $networkname1 -Location $locationName -SubnetId $virtualNetwork.Subnets[0].Id -PublicIpAddressId $publicIp.Id -force
}
ElseIf ($numberOfNics -eq 2){
    Write-Output "$(Get-Date -f $timeStampFormat) - creating 2 nics"
    $networkInterface1 = New-AzureRmNetworkInterface -ResourceGroupName $resourceGroupName -Name $networkname1 -Location $locationName -SubnetId $virtualNetwork.Subnets[0].Id -PublicIpAddressId $publicIp.Id -force
    $networkInterface2 = New-AzureRmNetworkInterface -ResourceGroupName $resourceGroupName -Name $networkname2 -Location $locationName -SubnetId $virtualNetwork.Subnets[1].Id -force
}
ElseIf ($numberOfNics -eq 3){
    Write-Output "$(Get-Date -f $timeStampFormat) - creating 3 nics"
    $networkInterface1 = New-AzureRmNetworkInterface -ResourceGroupName $resourceGroupName -Name $networkname1 -Location $locationName -SubnetId $virtualNetwork.Subnets[0].Id -PublicIpAddressId $publicIp.Id -force
    $networkInterface2 = New-AzureRmNetworkInterface -ResourceGroupName $resourceGroupName -Name $networkname2 -Location $locationName -SubnetId $virtualNetwork.Subnets[1].Id -force
    $networkInterface3 = New-AzureRmNetworkInterface -ResourceGroupName $resourceGroupName -Name $networkname3 -Location $locationName -SubnetId $virtualNetwork.Subnets[2].Id -force
}
ElseIf ($numberOfNics -eq 4){
    Write-Output "$(Get-Date -f $timeStampFormat) - creating 4 nics"
    $networkInterface1 = New-AzureRmNetworkInterface -ResourceGroupName $resourceGroupName -Name $networkname1 -Location $locationName -SubnetId $virtualNetwork.Subnets[0].Id -PublicIpAddressId $publicIp.Id -force
    $networkInterface2 = New-AzureRmNetworkInterface -ResourceGroupName $resourceGroupName -Name $networkname2 -Location $locationName -SubnetId $virtualNetwork.Subnets[1].Id -force
    $networkInterface3 = New-AzureRmNetworkInterface -ResourceGroupName $resourceGroupName -Name $networkname3 -Location $locationName -SubnetId $virtualNetwork.Subnets[2].Id -force
    $networkInterface4 = New-AzureRmNetworkInterface -ResourceGroupName $resourceGroupName -Name $networkname4 -Location $locationName -SubnetId $virtualNetwork.Subnets[2].Id -force
}
ElseIf ($numberOfNics -gt 4){
    Write-Output "$(Get-Date -f $timeStampFormat) - please enter a number between 1 and 4"
}

$vmConfig = New-AzureRmVMConfig -VMName $vmname -VMSize $vmsize
$password
$securePassword = ConvertTo-SecureString $password -AsPlainText -Force
$securePassword
$cred = New-Object System.Management.Automation.PSCredential ($user, $securePassword) 
$cred

# Set OS Profiles 
$vmConfig = Set-AzureRMVMOperatingSystem -VM $vmConfig -ComputerName $vmName -Credential $cred -Linux  

# Setup Disks - OS disk, and data disk of 30GB in size 
$vmConfig = Set-AzureRmVMOSDisk -VM $vmConfig -CreateOption fromimage -Linux -SourceImageUri $destinationVhd -VhdUri $osDiskUri -Name $osDiskName
#$vmConfig = Set-AzureRmVMOSDisk -VM $vmConfig -CreateOption fromimage -Linux -SourceImageUri $destinationVhd -VhdUri $dataDiskUri -Name $osDiskName
$vmConfig = Add-AzureRmVmDataDisk -vm $vmConfig -Name $dataDiskName -Caching 'ReadWrite' -DiskSizeInGB 30 -Lun 0 -VhdUri $dataDiskUri -CreateOption Empty

# Add NICs
if ($numberOfNics -eq 0){
    Write-Output "$(Get-Date -f $timeStampFormat) - please try again, number of nics should not be 0"
}
ElseIf ($numberOfNics -eq 1){
    Write-Output "$(Get-Date -f $timeStampFormat) - applying 1 nic"
    $vmConfig = Add-AzureRmVMNetworkInterface -VM $vmConfig -Id $networkInterface1.Id -Primary
}
ElseIf ($numberOfNics -eq 2){
    Write-Output "$(Get-Date -f $timeStampFormat) - applying 2 nics"
    $vmConfig = Add-AzureRmVMNetworkInterface -VM $vmConfig -Id $networkInterface1.Id -Primary
    $vmConfig = Add-AzureRmVMNetworkInterface -VM $vmConfig -Id $networkInterface2.Id
}
ElseIf ($numberOfNics -eq 3){
    Write-Output "$(Get-Date -f $timeStampFormat) - applying 3 nics"
    $vmConfig = Add-AzureRmVMNetworkInterface -VM $vmConfig -Id $networkInterface1.Id -Primary
    $vmConfig = Add-AzureRmVMNetworkInterface -VM $vmConfig -Id $networkInterface2.Id
    $vmConfig = Add-AzureRmVMNetworkInterface -VM $vmConfig -Id $networkInterface3.Id
}
ElseIf ($numberOfNics -eq 4){
    Write-Output "$(Get-Date -f $timeStampFormat) - applying 4 nics"
    $vmConfig = Add-AzureRmVMNetworkInterface -VM $vmConfig -Id $networkInterface1.Id -Primary
    $vmConfig = Add-AzureRmVMNetworkInterface -VM $vmConfig -Id $networkInterface2.Id
    $vmConfig = Add-AzureRmVMNetworkInterface -VM $vmConfig -Id $networkInterface3.Id
    $vmConfig = Add-AzureRmVMNetworkInterface -VM $vmConfig -Id $networkInterface4.Id 
}
ElseIf ($numberOfNics -gt 4){
    Write-Output "$(Get-Date -f $timeStampFormat) - please enter a number between 1 and 4"
}


If ($addSshKey -eq 1) {
  Write-Output "$(Get-Date -f $timeStampFormat) - Add sshkey for tester"
  Add-AzureRmVMSshPublicKey -VM $vmConfig -KeyData $keyData -Path "/home/$user/.ssh/authorized_keys"
  }  Else {
  Write-Output "$(Get-Date -f $timeStampFormat) - No sshkey"
} 

# Create a new FortiGate-VM
Write-Output "$(Get-Date -f $timeStampFormat) - creating vm"
New-AzureRmVM -VM $vmConfig -Location $locationName -ResourceGroupName $resourceGroupName

# END of the commands