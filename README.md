# Kubernetes Setup for Tharja

## (Local only) Setup HyperV machine

```sh
cd hyperv && ./create-vm.sh k8s
```

Then connect to machine and get ip

## Provisioning

1. Adapt `machines.json` and map "sidra": "<ip>"
2. Run provisioning.

```sh
./provision.sh <machineName> hobart
```


## After Host provisioning

### Copy config

scp hobart@192.168.178.103:/home/hobart/.kube/config ~/.kube/config-sidra


# Machine Provisioning for avsn.de Server

This project is for provisioning a bare metal Debian-based box using ansible and operating it with k8s.
It follows some principle of a plesk based server, while explicitly NOT using plesk.

It provides:

- ✅ Docker Setup
- ✅ k3s Setup
- ✅ Common things, libs, packages, CLIs
- ✅ Traefik reverse proxy
    - ✅ With rate limiting
    - ✅ HTTPS support (LetsEncrypt)
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
- ✅ Application firewall using CrowdSec
  - ✅ CrowdSec agent + LAPI deployed in `sys-crowdsec` namespace
  - ✅ Traefik bouncer plugin integration (`crowdsec-bouncer-traefik-plugin`)
  - ✅ Per-site opt-out via `crowdsec.enabled` in website chart
- ✅ Ntfy service
- ✅ Docker registry
- ✅ Authentik IDP, ready to use and configure.
- ✅ GameServers
  - ✅ Minecraft
    - ✅ Plugin management via k8s
  - ✅ ARK
    - ✅ Mod management via k8s
- ✅ CSI SMB Driver
  - (e.g.) to connect to Hetzner Storage Box
- ✅ DNS via bind9
- ✅ MariaDB Databases
- ✅ Postgres Databases (CNPG)
- ✅ Lets Encrypt / ACME Pebble (Local with self signed CA)
- ✅ VPN Client
- ✅ LocalStack Platform
  - ✅ with Security layer

## Requires

- Requires 1Password CLI and 1Password to be installed on the provisioning client.

## Kustomize
```sh
curl -s "https://raw.githubusercontent.com/kubernetes-sigs/kustomize/master/hack/install_kustomize.sh" | bash
sudo mv kustomize /usr/local/bin/
```

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

## Tests

### Lambda deployment to localstack

```sh
# Download and trust Intermediate CA
./utilities/trust-current-pebble.sh

# Make aws cli use it
aws configure set default.ca_bundle /etc/ssl/certs/ca-certificates.crt
aws configure set default.region eu-central-1

export AWS_ACCESS_KEY_ID=<key_id> && export AWS_SECRET_ACCESS_KEY=<access_key>

# inside tests/lambda-deployment
terraform apply

# List Lambda functions
aws --endpoint-url=https://cloud.sidra.codewyre.net lambda list-functions
aws --endpoint-url=https://cloud.sidra.codewyre.net \
  lambda invoke \
  --function-name arn:aws:lambda:eu-central-1:000000000042:function:hello-terraform-lambda \
  --cli-binary-format raw-in-base64-out \
  --payload '{}' \
  response.json

```