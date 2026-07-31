#!/usr/bin/env bash
rm -rf pebble-root-ca.crt

kubectl get --raw \
  '/api/v1/namespaces/sys-acme/services/https:acme-pebble:15000/proxy/roots/0' \
  > pebble-root-ca.crt

echo "Installing..."
sudo cp ./pebble-root-ca.crt /usr/local/share/ca-certificates/pebble-root-ca.crt
sudo update-ca-certificates --fresh

echo "Installing CA (Windows)..."
cp ./trust-current-pebble.ps1 /mnt/c/Windows/Temp/trust-current-pebble.ps1
cp ./pebble-root-ca.crt /mnt/c/Windows/Temp/pebble-root-ca.crt

powershell.exe -Command \
  "Start-Process PowerShell -Verb RunAs -ArgumentList '-ExecutionPolicy Bypass -File C:\\Windows\\Temp\\trust-current-pebble.ps1'"

echo "Done."