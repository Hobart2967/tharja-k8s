#!/bin/sh

NAME=$1
if [ -z "$NAME" ]; then
  echo "Missing argument for name"
  exit 400
fi

mkdir -p /mnt/c/VMs
mkdir -p /mnt/c/VMs/ISOs

if [ ! -f "/mnt/c/VMs/ISOs/ubuntu-25.10-live-server-amd64.iso" ]; then
  echo "Missing ISO file: ubuntu-25.10-live-server-amd64.iso"
  exit 400
fi

rm -rf seed.iso
./generate-iso.sh || exit 500
cp seed.iso /mnt/c/VMs/ISOs/seed.iso

cp ./create-vm.ps1 /mnt/c/VMs/create-vm.ps1

powershell.exe -Command \
  "Start-Process PowerShell -Verb RunAs -ArgumentList '-ExecutionPolicy Bypass -File C:\\VMs\\create-vm.ps1 -Name $NAME'"