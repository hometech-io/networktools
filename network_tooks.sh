#!/bin/bash

imageURL=https://mbellido.com/networktools_iotech_tools.tar.gz
imageName="networktools_iotech_tools.qcow2"
imageNameCompressed="networktools_iotech_tools.tar.gz"
volumeName="local-lvm"
templateName="networktools"
cores="1"
memory="1024"
cpuTypeRequired="host"

## Questions

function questions() {
  # Vm Id
  backtitle="Networks Tools Installation"
  if virtualMachineId=$(whiptail --backtitle "$backtitle" --inputbox "Set VM Id" 0 0 500 --title "VM Id" --cancel-button Exit 3>&1 1>&2 2>&3); then
    if [ -z $virtualMachineId ]; then
      exit
    fi
  else
    exit
  fi
}


questions

rm *.tar.gz *.qcow2
wget -O $imageNameCompressed $imageURL
tar -xzvf $imageNameCompressed
qm create $virtualMachineId --name $templateName --memory $memory --cores $cores --net0 virtio,bridge=vmbr0
qm importdisk $virtualMachineId $imageName $volumeName
qm set $virtualMachineId --scsihw virtio-scsi-pci --scsi0 $volumeName:vm-$virtualMachineId-disk-0
qm set $virtualMachineId --boot c --bootdisk scsi0
qm set $virtualMachineId --serial0 socket --vga serial0
qm set $virtualMachineId --cpu cputype=$cpuTypeRequired
qm start $virtualMachineId
