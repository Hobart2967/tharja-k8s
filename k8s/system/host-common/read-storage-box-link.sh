#!/bin/sh
if [ "$#" -ne 2 ]; then
  echo "Usage: $0 <namespace> <secret>"
  exit 1
fi

echo "Extracting consumer values from secret $2 in namespace $1"

rm -rf .tmp
mkdir -p .tmp

YQ_VERSION=$(yq --version 2>/dev/null || true)
if echo "$YQ_VERSION" | grep -qi "mikefarah"; then
  DOMAIN=$(kubectl -n "$1" get secret $2 -o yaml  | yq eval '.data.domain | from_yaml' -)
  echo $DOMAIN
  DOMAIN=$(echo "$DOMAIN" | base64 --decode)

  HOST_NICKNAME=$(kubectl -n default get configmap host-metadata -o yaml | yq eval '.data.hostNickname' -)

  cat <<EOF > .tmp/values.yaml
  storageClasses:
  - name: smb-csi
    annotations:
      storageclass.kubernetes.io/is-default-class: "true"
    parameters:
      source: "//${DOMAIN}/backup/${HOST_NICKNAME}"
      # if csi.storage.k8s.io/provisioner-secret is provided, will create a sub directory
      # with PV name under source
      csi.storage.k8s.io/provisioner-secret-name: $2
      csi.storage.k8s.io/provisioner-secret-namespace: $1
      csi.storage.k8s.io/node-stage-secret-name: $2
      csi.storage.k8s.io/node-stage-secret-namespace: $1
    reclaimPolicy: Delete
    volumeBindingMode: Immediate
    allowVolumeExpansion: true
    mountOptions:
      - dir_mode=0777
      - file_mode=0777
      - noperm
      - mfsymlinks
      - cache=strict
      - noserverino  # required to prevent data corruption
  - name: smb-csi-retain
    parameters:
      source: "//${DOMAIN}/backup/${HOST_NICKNAME}"
      # if csi.storage.k8s.io/provisioner-secret is provided, will create a sub directory
      # with PV name under source
      csi.storage.k8s.io/provisioner-secret-name: $2
      csi.storage.k8s.io/provisioner-secret-namespace: $1
      csi.storage.k8s.io/node-stage-secret-name: $2
      csi.storage.k8s.io/node-stage-secret-namespace: $1
    reclaimPolicy: Retain
    volumeBindingMode: Immediate
    allowVolumeExpansion: true
    mountOptions:
      - dir_mode=0777
      - file_mode=0777
      - noperm
      - mfsymlinks
      - cache=strict
      - noserverino  # required to prevent data corruption
  - name: smb-csi-retain-readcache
    parameters:
      source: "//${DOMAIN}/backup/${HOST_NICKNAME}"
      # if csi.storage.k8s.io/provisioner-secret is provided, will create a sub directory
      # with PV name under source
      csi.storage.k8s.io/provisioner-secret-name: $2
      csi.storage.k8s.io/provisioner-secret-namespace: $1
      csi.storage.k8s.io/node-stage-secret-name: $2
      csi.storage.k8s.io/node-stage-secret-namespace: $1
    reclaimPolicy: Retain
    volumeBindingMode: Immediate
    allowVolumeExpansion: true
    mountOptions:
      - dir_mode=0777
      - file_mode=0777
      - noperm
      - mfsymlinks
      - cache=loose
      - actimeo=30
      - noserverino  # keep inode behavior consistent with the strict classes
EOF
else
  echo "This script requires mikefarah yq for parsing config YAML strings"
  exit 1
fi