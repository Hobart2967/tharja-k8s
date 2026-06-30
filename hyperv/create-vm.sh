#!/bin/sh

NAME=$1
if [ -z "$NAME" ]; then
  echo "Missing argument for name"
  exit 400
fi

mkdir -p /mnt/c/VMs
mkdir -p /mnt/c/VMs/ISOs

rm -rf seed.iso
./generate-iso.sh
cp seed.iso /mnt/c/VMs/ISOs/seed.iso

cp ./create-vm.ps1 /mnt/c/VMs/create-vm.ps1

powershell.exe -Command \
  "Start-Process PowerShell -Verb RunAs -ArgumentList '-ExecutionPolicy Bypass -File C:\\VMs\\create-vm.ps1 -Name $NAME'"