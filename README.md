## After Host provisioning

### Copy config
scp user@192.168.178.95:/etc/rancher/k3s/k3s.yaml ~/.kube/config-hostname


# Machine Provisioning for avsn.de Server

This ansible project is for provisioning a bare metal Debian-based box. It follows some principle of a plesk based server, while explicitly NOT using plesk.

It provides:

- ✅ Docker Setup
  - ✅ Including it having iptables support disabled, while allowing containers to connect to the outside
  - ✅ Everything runs stuck behind firewall, except SSH and firewall itself.
  - ✅ Every environment runs in it own subnet with fixed ip range and every container can be configured with a fixed IP
- ✅ Common things, libs, packages, CLIs
- ✅ OhMyZsh, including my shell setup
- ✅ ASDF Setup
  - ✅ Java,
  - ✅ C#,
  - ✅ Terraform,
  - ✅ Node,
  - ✅ Python,
  - ✅ Maven,
  - ✅ awscli
- ✅ nginx reverse proxy setup with rate limiting and HTTPS support (LetsEncrypt)
- ✅ Dockerized Web Server Setup
  - ✅ Supports nginx
  - ✅ Supports a PHP armored apache instance
- ✅ Monitoring Setup using Grafana
  - ✅ Comes pre-configured with prometheus and loki
  - ✅ Dashboard import support for dashboards from https://grafana.com/grafana/dashboards/
  - ✅ Easy Contact point config in variables
- ✅ MailServer Setup
  - ✅ Postfix
  - ✅ Dovecot
  - ✅ Webmail
  - ✅ Spam Protection
  - ✅ Virus Protection
  - ✅ Multi-Domain
- ✅ UFW Firewall setup
  - ✅ Firewall general installation
  - ✅ Systemd service for ufw.
- ✅ Ntfy service
- ✅ GameServers
  - ✅ Minecraft
    - ✅ Plugin management via ansible
  - ✅ ARK
    - ✅ Mod management via ansible
- ✅ DNS via bind9
  - ✅ Denic NAST Predelegation check compatible config samples
- ✅ MariaDB Databases
- ✅ Fail2Ban, connected to:
  - ✅ IMAP (Dovecot)
  - ✅ Postfix Jail
  - Current issue: Docker internal IP is getting banned instead of the public one.
  - ✅ UFW, the firewall configured.
- ❌ModSecurity
- ✅ Lets Encrypt
- ❌VPN Client
- ❌Sudo with TOTP: https://www.reddit.com/r/selfhosted/comments/h02wzr/how_to_adding_totp_to_sudo/?show=original
- ❌ Logrotation
- ❌ backups

## Requires

- Requires 1Password CLI and 1Password to be installed on the provisioning client.

## Environments

- `sidra`: Staging test environment
- `tharja`: Production Server

## Usage

### Prerequisites

#### Required Tools

| Name            | Version   |
| :-------------- | :-------- |
| Python  | ^3.0.0 |
| Pip | latest |
| Ansible | latest |

#### Workspace Preparation

##### Setting up your keepass vault

Create a new or download an existing keepass file to your hard drive. This file should contain users, passwords and servers needed for setting up the remote system connection between the database server and the provisioned one.

##### Setting up Ansible

```sh
python3 -m pip install --user ansible
```

### Run

```sh
./provision.sh <sidra|tharja> hobart
```

## Infrastructural Dependencies

- 1Password

## Setup VM with Virtualbox unattended

```sh
sudo apt install -y openssh-server \
  && sudo dpkg-reconfigure keyboard-configuration\
  && sudo setupcon
```

sudo firewall-cmd --zone public --add-port=80/tcp
mariadb -uroot -P3306 -h172.118.0.3 -p usr_web1_1 < dump20250507.sql

```
sudo rsync -auvz --rsync-path="sudo rsync" hobart@elanor:/backups/tharja/fs/storage/vhosts/adventurespiele.net/httpdocs/ \
  --exclude=9891 \
  --exclude=Bilder \
  --exclude=Downloads \
  --exclude=images \
  --exclude=modules/My_eGallery/gallery \
  --exclude=teamupload \
  --exclude=avsn \
  --exclude=cache \
  --exclude=httpdocs.phpproj2 \
  --exclude=icon \
  --exclude=Onlinegames \
  --exclude=Uploads \
	/storage/vhosts/de.avsn/httpdocs/


rsync -auvz --rsync-path="sudo rsync" root@avsn.de:/storage/vhosts/adventurespiele.net/httpdocs/ /storage/vhosts/de.avsn/httpdocs/

sudo mkdir -p /storage/vhosts/de.avsn/httpdocs/pnTemp/pnRender_compiled
sudo chmod 0777 /storage/vhosts/de.avsn/httpdocs/pnTemp
sudo chmod 0777 /storage/vhosts/de.avsn/httpdocs/pnTemp/pnRender_compiled
sudo mkdir -p /storage/vhosts/de.avsn/httpdocs/pnTemp/Xanthia_compiled
sudo chmod 0777 /storage/vhosts/de.avsn/httpdocs/pnTemp/Xanthia_compiled
  ```



## Documentation

### ASDF

Asdf is preconfigured and preinstalled with the plugins listed in the ansible playbook variables.
It is configured in a way that only root/sudoers can install plugins and versions, while users can use the installed things.