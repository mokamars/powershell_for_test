#---------------------------------------------------------------------------------------------------------------------~
#README

#First create the folder where you will store all the files and fill the varable $path_to_storage
#Please also fill the networker iso variable with the correct path to the ISO

#CSV File need to look like this :
#TODO : Need to implement correctly the Disks management. Need inputs from DELL
#name;memory;disks
#VMNAME;80000;C:SYSTEM:52666764-D:DATA:55331836
#---------------------------------------------------------------------------------------------------------------------

$computer_list = Import-Csv listing_vm.txt

ForEach ($item in $computer_list) { 
    #---------------------------------------------------------------------------------------------------------------------
    #VARIABLES
    #---------------------------------------------------------------------------------------------------------------------
    $vm_name = $($item.vm_name)
    $vm_memory = $($item.vm_memory)
    $vm_disk_c = $($item.vm_disk_c)
    $vm_disk_d = $($item.vm_disk_d)

    Write-host $vm_name
    Write-host $vm_memory

    #TODO : Create variables from the csv file if VM has more than one disk
    Write-Host $vm_disk_c
    Write-Host $vm_disk_d
    
    #Variable to stroe the folder path where all the files are stored
    $path_to_storage = "c:\vm-Machine"

    #Path to the VHD File for each disk
    #TODO : Need to implement ?
    $path_to_vhd = "$($path_to_storage)\$vm_name\$($vm_name)_$vm_disk_c.vhdx"

    #Path to the networker ISO
    $networker_iso = "C:\vm-machine\networker_image.iso"
    #---------------------------------------------------------------------------------------------------------------------
    

    #---------------------------------------------------------------------------------------------------------------------
    #VM CREATION

    #Generation parameter is OS dependant 
    #TODO : Implement Generation value by OS found in the csv file
    #New-VM -Name bcnssrv867 -path C:\vm-machine\bcnssrv867 -MemoryStartupBytes 8000MB -Generation 2
    #---------------------------------------------------------------------------------------------------------------------
    $vm = "New-VM -Name $vm_name -path $($path_to_storage)\$vm_name -MemoryStartupBytes $vm_memory -Generation 2"
    Write-Host $vm
    Invoke-Expression $vm    
    #---------------------------------------------------------------------------------------------------------------------

    #---------------------------------------------------------------------------------------------------------------------
    #Create a Dynamic disk And attach it to the VM
    #---------------------------------------------------------------------------------------------------------------------    
    $hdd = "New-VHD -Path c:\vm-Machine\$vm_name\$($vm_name)_$vm_disk_c.vhdx -SizeBytes $vm_disk_c -Dynamic"
    Write-Host $hdd
    Invoke-Expression $hdd
    
    #Create a Fixed disk
    #TODO : Need to implement a mechanism to detect if the disk need Dynamic or fixed size ?
    #Write-Host "New-VHD -Path c:\vm-Machine\$vm_name\$($vm_name)_$vm_disk_d.vhdx -SizeBytes $vm_disk_d -Fixed"

    #Attach the disk
    #Attach every disk needed. loop ?
    #Add-VMHardDiskDrive -VMName bcnssrv867 -path c:\vm-Machine\bcnssrv867\bcnssrv867_52GB.vhdx"
    $attach_vhd = "Add-VMHardDiskDrive -VMName $vm_name -path $path_to_vhd"
    Write-Host $attach_vhd
    Invoke-Expression $attach_vhd
    #---------------------------------------------------------------------------------------------------------------------
    
    #---------------------------------------------------------------------------------------------------------------------
    #CONFIGURE THE DVD DRIVE
    #---------------------------------------------------------------------------------------------------------------------
    #Add the path to the networker image
    #The networker image needs to be copied on the computers
    
    $dvd_configuration = "Set-VMDvdDrive -VMName $vm_name -Path $networker_iso"
    Write-Host $dvd_configuration
    Invoke-Expression $dvd_configuration
    #---------------------------------------------------------------------------------------------------------------------
    #---------------------------------------------------------------------------------------------------------------------
    
    #---------------------------------------------------------------------------------------------------------------------
    #CONFIGURE THE VM SWITCH AND NETWORK
    #---------------------------------------------------------------------------------------------------------------------
    #Connect the correct switch to the vm
    Connect-VMNetworkAdapter -VMName bcnssrv867 -SwitchName "Default Switch"

    #Configure Access Virtual LAN Identification (-Access) and set ID (121 in the example)    
    #TODO : Need to define the correct value for the VLAN ? Always the same ?
    $vlan_configuration = "Set-VMNetworkAdapterVlan -VMName $vm_name -Access -VlanId 121"
    Invoke-Expression $vlan_configuration
    #---------------------------------------------------------------------------------------------------------------------
}