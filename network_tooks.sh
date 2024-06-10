#!/bin/bash

imageURL=https://mbellido.com/networktools_hometech.tar.gz
imageName="networktools_hometech.qcow2"
imageNameCompressed="networktools_hometech.tar.gz"
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

  # Root Password
  if rootPasswd=$(whiptail --backtitle "$backtitle" --inputbox "Set root password" 0 0 --title "Root password" --cancel-button Exit 3>&1 1>&2 2>&3); then
    if [ -z $rootPasswd ]; then
      exit
    fi
  else
    exit
  fi

  # Cloudfare Domain Zone
  if ! ddclient_domainzone=$(whiptail --backtitle "$backtitle" --inputbox "Cloudflare Domain Zone" 0 0 --title "Domain Zone" --cancel-button Exit 3>&1 1>&2 2>&3); then
    exit
  fi

  # Cloudfare API Token
  if ! ddclient_apitoken=$(whiptail --backtitle "$backtitle" --inputbox "Cloudflare API Token" 0 0 --title "API Token" --cancel-button Exit 3>&1 1>&2 2>&3); then
    exit
  fi

  # Cloudfare Subdomains
  if ! dd_client_subdomains=$(whiptail --backtitle "$backtitle" --inputbox "Cloudflare Subdomain/s" 0 0 --title "Subdomain/s" --cancel-button Exit 3>&1 1>&2 2>&3); then
    exit
  fi
}


questions

apt update
apt install libguestfs-tools -y
rm *.tar.gz *.qcow2
wget -O $imageNameCompressed $imageURL
tar -xzvf $imageNameCompressed
virt-customize -a $imageName --root-password password:$rootPasswd
virt-customize -a $imageName --run-command "sed -i 's/DOMAIN_ZONE/${ddclient_domainzone}/g; s/API_TOKEN/${ddclient_apitoken}/g; s/SUBDOMAINS/${dd_client_subdomains}/g;' /root/docker/ddclient/config/ddclient.conf"
qm create $virtualMachineId --name $templateName --memory $memory --cores $cores --net0 virtio,bridge=vmbr0
qm importdisk $virtualMachineId $imageName $volumeName
qm set $virtualMachineId --scsihw virtio-scsi-pci --scsi0 $volumeName:vm-$virtualMachineId-disk-0
qm set $virtualMachineId --boot c --bootdisk scsi0
qm set $virtualMachineId --serial0 socket --vga serial0
qm set $virtualMachineId --ipconfig0 ip=dhcp
qm set $virtualMachineId --cpu cputype=$cpuTypeRequired
qm start $virtualMachineId
