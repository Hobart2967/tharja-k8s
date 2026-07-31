#!/bin/sh
if [ "$#" -ne 1 ]; then
  echo "Usage: $0 <mailserver-domain>"
  exit 1
fi

DOMAIN=$1

echo "Calculating stage domain for productive domain $DOMAIN"

mkdir -p .tmp

# Mimic logic from "k8s/helm/cert-request/templates/_stage-domain.tpl" and save it to .tmp/domain.yaml
YQ_VERSION=$(yq --version 2>/dev/null || true)
if echo "$YQ_VERSION" | grep -qi "mikefarah"; then
  HOST_NICKNAME=$(kubectl -n default get configmap host-metadata -o yaml | yq eval '.data.hostNickname' -)
  echo "Host nickname: $HOST_NICKNAME"
  if [ "$HOST_NICKNAME" = "tharja" ]; then
    STAGE_DOMAIN=$DOMAIN
  else
    STAGE_DOMAIN="${HOST_NICKNAME}.${DOMAIN}"
  fi
  rm -rf .tmp/domain.yaml
  cat <<EOF > .tmp/domain.yaml
imap:
  host: ${STAGE_DOMAIN}
  port: 143
  encryption: starttls
smtp:
  host: ${STAGE_DOMAIN}

EOF
else
  echo "This script requires mikefarah yq for parsing config YAML strings"
  exit 1
fi