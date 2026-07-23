# In case of DNS problems
sudo nano /etc/netplan/$(sudo ls /etc/netplan)

```yaml
ethernets:
  eth0:
    dhcp4: true
    dhcp6: true
    dhcp4-overrides:
      use-dns: false
    dhcp6-overrides:
      use-dns: false
    nameservers:
      addresses:
        - 1.1.1.1
        - 1.0.0.1
        - 2606:4700:4700::1111
        - 2606:4700:4700::1001
      search: []
```

Then:
```
sudo netplan try
sudo netplan generate
sudo netplan apply

# Test:
resolvectl status

# Reboot:
sudo reboot
```