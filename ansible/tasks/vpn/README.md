# VPN Configuration Example

This directory contains Ansible tasks for configuring VPN connections using strongSwan IPsec.

## Configuration

Add VPN configuration to your machine's vars file (e.g., `vars/tharja.yml`):

```yaml
provision:
  vpn: true

vpn:
  # Optional: Configure firewall rules (default: true)
  firewall_rules: true

  # Optional: IPsec global settings
  ipsec:
    charon_debug: "ike 1, knl 1, cfg 0"
    unique_ids: "no"

  # Define your VPN connections
  connections:
    - name: fritzbox
      # Connection parameters
      keyexchange: ikev1
      ike: aes256-sha1-modp1024!
      esp: aes256-sha1!

      # Local (left) side configuration
      left: "%defaultroute"
      leftauth: psk
      leftid: "your-identifier@yourdomain.com"
      # leftsubnet: 192.168.1.0/24  # Optional: local subnet

      # Remote (right) side configuration
      right: "fritzbox.example.com"  # or IP address
      rightauth: psk
      rightid: "fritzbox-identifier"
      rightsubnet: "192.168.178.0/24"  # FritzBox LAN subnet

      # Pre-shared key
      psk: "your-pre-shared-key-here"

      # Connection behavior
      auto: start  # auto-start connection
      auto_start: true  # Bring up after configuration
      dpdaction: restart
      dpddelay: 30s
      dpdtimeout: 120s
```

## FritzBox Specific Configuration

For connecting to a FritzBox router:

1. **On FritzBox:**
   - Go to Internet → Permit Access → VPN
   - Create a new IPsec connection
   - Note the identifier and pre-shared key
   - Enable the connection

2. **Common FritzBox settings:**
   - Default LAN subnet: `192.168.178.0/24`
   - Key exchange: IKEv1
   - IKE: `aes256-sha1-modp1024`
   - ESP: `aes256-sha1`

## Usage

1. Enable VPN provisioning in your machine vars:
   ```yaml
   provision:
     vpn: true
   ```

2. Add your VPN configuration under the `vpn:` key

3. Run your provision script:
   ```bash
   ./provision.sh <machine> <user>
   ```

## Firewall

The task automatically configures firewalld to allow:
- UDP port 500 (IKE)
- UDP port 4500 (NAT-T)
- Protocol ESP

## Manual Operations

Check VPN status:
```bash
sudo ipsec status
sudo ipsec statusall
```

Bring connection up/down manually:
```bash
sudo ipsec up fritzbox
sudo ipsec down fritzbox
```

View logs:
```bash
sudo journalctl -u strongswan-starter -f
```

## Troubleshooting

- Ensure your FritzBox is reachable from the server
- Verify the pre-shared key matches on both sides
- Check that identifiers match the FritzBox configuration
- Review logs: `sudo journalctl -u strongswan-starter`
- Test connectivity: `ping 192.168.178.1` (FritzBox IP)
